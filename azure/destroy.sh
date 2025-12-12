#!/usr/bin/env bash
set -eo pipefail

echo "========================================="
echo "AKS Cluster Destruction Script"
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

# Step 2: Authenticate to Azure using Service Principal
echo ""
echo "Step 2: Authenticating to Azure..."
az login --service-principal \
    --username "$AZURE_CLIENT_ID" \
    --password "$AZURE_CLIENT_SECRET" \
    --tenant "$AZURE_TENANT_ID" > /dev/null

# Step 3: Auto-detect Azure Subscription
echo ""
echo "Step 3: Auto-detecting Azure Subscription..."
export AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Detected Subscription ID: $AZURE_SUBSCRIPTION_ID"

# Step 4: Auto-detect Resource Group
echo ""
echo "Step 4: Auto-detecting Resource Group..."
export AZURE_RESOURCE_GROUP=$(az group list --query "[0].name" -o tsv)
echo "Detected Resource Group: $AZURE_RESOURCE_GROUP"

# Step 5: Get location from the Resource Group
export AZURE_LOCATION=$(az group show --name "$AZURE_RESOURCE_GROUP" --query location -o tsv)
echo "Detected Location: $AZURE_LOCATION"

# Export credentials for Terraform
export AZURE_TENANT_ID="$AZURE_TENANT_ID"
export AZURE_CLIENT_ID="$AZURE_CLIENT_ID"
export AZURE_CLIENT_SECRET="$AZURE_CLIENT_SECRET"

# Step 6: Run Terraform Destroy
echo ""
echo "Step 6: Destroying AKS cluster using Terraform..."
cd terraform/

# Generate storage account name (must match start.sh)
HASH=$(echo -n "$AZURE_SUBSCRIPTION_ID" | md5sum | cut -c1-14)
STORAGE_ACCOUNT_NAME="akstfstate${HASH}"
CONTAINER_NAME="tfstate"

terraform init \
    -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
    -backend-config="container_name=$CONTAINER_NAME" \
    -backend-config="key=aks.tfstate" \
    -backend-config="resource_group_name=$AZURE_RESOURCE_GROUP"
echo ""
echo "WARNING: This will destroy all resources created by Terraform!"
echo ""
terraform destroy -auto-approve

echo ""
echo "========================================="
echo "AKS Cluster Destruction Complete!"
echo "========================================="
echo ""
echo "All resources have been cleaned up."
