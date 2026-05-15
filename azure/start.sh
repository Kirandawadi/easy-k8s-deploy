#!/usr/bin/env bash
set -eo pipefail

echo "========================================="
echo "AKS Cluster Deployment Script"
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

# Step 3: Auto-detect Subscription ID
echo ""
echo "Step 3: Auto-detecting Azure Subscription..."
export AZURE_SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Detected Subscription ID: $AZURE_SUBSCRIPTION_ID"

# Step 4: Set the subscription as active
echo ""
echo "Step 4: Setting active subscription..."
az account set --subscription "$AZURE_SUBSCRIPTION_ID"
echo "Active subscription set to: $AZURE_SUBSCRIPTION_ID"

# Step 5: Set Resource Group
# echo ""
# echo "Step 5: Auto-detecting Resource Group..."
# export AZURE_RESOURCE_GROUP=$(az group list --query "[0].name" -o tsv)
# echo "Detected Resource Group: $AZURE_RESOURCE_GROUP"
export AZURE_RESOURCE_GROUP="TestRG" # Hardcoded for now

# Step 6: Get location from the Resource Group
# export AZURE_LOCATION=$(az group show --name "$AZURE_RESOURCE_GROUP" --query location -o tsv)
# echo "Detected Location: $AZURE_LOCATION"

export AZURE_LOCATION="centralus" # Hardcoded for now

# Step 7: Export credentials for Terraform (both AZURE_* for external data source and ARM_* for backend)
export AZURE_TENANT_ID="$AZURE_TENANT_ID"
export AZURE_CLIENT_ID="$AZURE_CLIENT_ID"
export AZURE_CLIENT_SECRET="$AZURE_CLIENT_SECRET"

# ARM_* variables are used by Terraform azurerm backend for Service Principal authentication
export ARM_SUBSCRIPTION_ID="$AZURE_SUBSCRIPTION_ID"
export ARM_TENANT_ID="$AZURE_TENANT_ID"
export ARM_CLIENT_ID="$AZURE_CLIENT_ID"
export ARM_CLIENT_SECRET="$AZURE_CLIENT_SECRET"

# Step 8: Create Azure Storage Account for Terraform state
echo ""
echo "Step 8: Creating Azure Storage Account for Terraform state..."
# Generate unique storage account name from subscription ID (max 24 chars, lowercase/numbers only)
HASH=$(echo -n "$AZURE_SUBSCRIPTION_ID" | md5sum | cut -c1-14)
STORAGE_ACCOUNT_NAME="akstfstate${HASH}"
CONTAINER_NAME="tfstate"

echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"

# Check if storage account exists
if ! az storage account show --name "$STORAGE_ACCOUNT_NAME" --resource-group "$AZURE_RESOURCE_GROUP" &>/dev/null; then
    echo "Creating storage account $STORAGE_ACCOUNT_NAME..."
    az storage account create \
        --name "$STORAGE_ACCOUNT_NAME" \
        --resource-group "$AZURE_RESOURCE_GROUP" \
        --location "$AZURE_LOCATION" \
        --sku Standard_LRS \
        --kind StorageV2 \
        --allow-blob-public-access false
    echo "Storage account created."
else
    echo "Storage account $STORAGE_ACCOUNT_NAME already exists."
fi

# Get storage account key
STORAGE_ACCOUNT_KEY=$(az storage account keys list \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --query "[0].value" -o tsv)

# Check if container exists
if ! az storage container show \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --account-key "$STORAGE_ACCOUNT_KEY" &>/dev/null; then
    echo "Creating container $CONTAINER_NAME..."
    az storage container create \
        --name "$CONTAINER_NAME" \
        --account-name "$STORAGE_ACCOUNT_NAME" \
        --account-key "$STORAGE_ACCOUNT_KEY"
    echo "Container created."
else
    echo "Container $CONTAINER_NAME already exists."
fi

# Step 9: Run Terraform
echo ""
echo "Step 9: Deploying AKS cluster using Terraform..."
cd terraform/

terraform init \
    -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME" \
    -backend-config="container_name=$CONTAINER_NAME" \
    -backend-config="key=aks.tfstate" \
    -backend-config="resource_group_name=$AZURE_RESOURCE_GROUP"
echo ""
terraform plan
echo ""
terraform apply -auto-approve

# Step 10: Configure kubectl
echo ""
echo "Step 10: Configuring kubectl access..."
CLUSTER_NAME=$(terraform output -raw cluster_name)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)

az aks get-credentials \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CLUSTER_NAME" \
    --overwrite-existing

# Step 11: Verify cluster
echo ""
echo "Step 11: Verifying cluster..."
kubectl get nodes

echo ""
echo "========================================="
echo "AKS Cluster Deployment Complete!"
echo "========================================="
echo ""
echo "Cluster Name: $CLUSTER_NAME"
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $AZURE_LOCATION"
echo ""
echo "You can now use kubectl to interact with your cluster."
