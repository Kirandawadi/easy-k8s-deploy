#!/usr/bin/env bash
set -eo pipefail

echo "========================================="
echo "GKE Cluster Destruction Script"
echo "========================================="

# Step 1: Install Terraform using tfenv
echo ""
echo "Step 1: Installing Terraform 1.7.0..."
if [ ! -d "$HOME/.tfenv" ]; then
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv
    mkdir -p ~/bin
    ln -s ~/.tfenv/bin/* ~/bin/ 2>/dev/null || true
    export PATH=$PATH:~/bin/
fi
tfenv install 1.7.0 || true
tfenv use 1.7.0

# Step 2: Construct Service Account JSON from environment variables
echo ""
echo "Step 2: Creating service account credentials..."

# Create a temporary directory for credentials
CRED_DIR=$(mktemp -d)
CRED_FILE="$CRED_DIR/gcp-key.json"

PROJECT_ID="${GOOGLE_PROJECT_ID}"

# Escape the private key for JSON
PRIVATE_KEY_ESCAPED=$(echo "$GOOGLE_PRIVATE_KEY" | sed 's/$/\\n/' | tr -d '\n' | sed 's/\\n$//')

# Create the service account JSON file
cat > "$CRED_FILE" <<EOF
{
  "type": "service_account",
  "project_id": "$PROJECT_ID",
  "private_key": "$PRIVATE_KEY_ESCAPED",
  "client_email": "$GOOGLE_SERVICE_ACCOUNT_EMAIL",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs"
}
EOF

# Export credentials file path
export GOOGLE_APPLICATION_CREDENTIALS="$CRED_FILE"
export GOOGLE_PROJECT_ID="$PROJECT_ID"

echo "Service account credentials created at: $CRED_FILE"

# Step 3: Authenticate to GCP
echo ""
echo "Step 3: Authenticating to GCP..."
gcloud auth activate-service-account "$GOOGLE_SERVICE_ACCOUNT_EMAIL" --key-file="$CRED_FILE"

# Step 4: Run Terraform Destroy
echo ""
echo "Step 4: Destroying GKE cluster using Terraform..."
cd terraform/

BUCKET_NAME="gke-tfstate-${PROJECT_ID}"
terraform init -backend-config="bucket=$BUCKET_NAME"
echo ""
echo "WARNING: This will destroy all resources created by Terraform!"
echo ""
terraform destroy -auto-approve

echo ""
echo "========================================="
echo "GKE Cluster Destruction Complete!"
echo "========================================="
echo ""
echo "All resources have been cleaned up."

# Cleanup credentials file
rm -rf "$CRED_DIR"
