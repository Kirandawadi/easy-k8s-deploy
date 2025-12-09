#!/usr/bin/env bash
set -eo pipefail

echo "========================================="
echo "GKE Cluster Deployment Script"
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

# Construct the service account JSON file
# Extract project_id from service account email (format: sa-name@PROJECT_ID.iam.gserviceaccount.com)
PROJECT_ID="${GOOGLE_PROJECT_ID}"

# Escape the private key for JSON (replace newlines with \n)
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

# Step 4: Install GKE gcloud auth plugin
echo ""
echo "Step 4: Installing GKE gcloud auth plugin..."
# Add Google Cloud SDK repository if not present
if ! grep -q "cloud-sdk" /etc/apt/sources.list.d/* 2>/dev/null; then
    echo "Adding Google Cloud SDK repository..."
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
fi
sudo apt-get update -qq
sudo apt-get install -y google-cloud-cli-gke-gcloud-auth-plugin

# Step 5: Create GCS bucket for Terraform state
echo ""
echo "Step 5: Creating GCS bucket for Terraform state..."
BUCKET_NAME="gke-terraform-state-bucket"
if ! gsutil ls -b "gs://$BUCKET_NAME" 2>/dev/null; then
    echo "Creating bucket $BUCKET_NAME..."
    gsutil mb -p "$PROJECT_ID" -l us-central1 "gs://$BUCKET_NAME"
    gsutil versioning set on "gs://$BUCKET_NAME"
    echo "Bucket created and versioning enabled."
else
    echo "Bucket $BUCKET_NAME already exists."
fi

# Step 6: Run Terraform
echo ""
echo "Step 6: Deploying GKE cluster using Terraform..."
cd terraform/

terraform init
echo ""
terraform plan
echo ""
terraform apply -auto-approve

# Step 7: Configure kubectl
echo ""
echo "Step 7: Configuring kubectl access..."
CLUSTER_NAME=$(terraform output -raw cluster_name)
CLUSTER_LOCATION=$(terraform output -raw cluster_location)

gcloud container clusters get-credentials "$CLUSTER_NAME" \
    --region "$CLUSTER_LOCATION" \
    --project "$PROJECT_ID"

# Step 8: Verify cluster
echo ""
echo "Step 8: Verifying cluster..."
kubectl get nodes

echo ""
echo "========================================="
echo "GKE Cluster Deployment Complete!"
echo "========================================="
echo ""
echo "Cluster Name: $CLUSTER_NAME"
echo "Location: $CLUSTER_LOCATION"
echo "Project ID: $PROJECT_ID"
echo ""
echo "You can now use kubectl to interact with your cluster."
echo ""
