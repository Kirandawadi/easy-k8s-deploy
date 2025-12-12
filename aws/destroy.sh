#!/usr/bin/env bash
set -eo pipefail

echo "========================================="
echo "EKS Cluster Destruction Script"
echo "========================================="

# Step 1: Install Terraform using tfenv
echo ""
echo "Step 1: Installing Terraform 1.2.5..."
if [ ! -d "$HOME/.tfenv" ]; then
    git clone https://github.com/tfutils/tfenv.git ~/.tfenv
    mkdir -p ~/bin
    ln -s ~/.tfenv/bin/* ~/bin/ 2>/dev/null || true
    export PATH=$PATH:~/bin/
fi
tfenv install 1.2.5 || true
tfenv use 1.2.5

# Step 2: Configure AWS credentials
echo ""
echo "Step 2: Configuring AWS credentials..."
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

echo "AWS credentials configured for region: $AWS_DEFAULT_REGION"

# Step 3: Run Terraform Destroy
echo ""
echo "Step 3: Destroying EKS cluster using Terraform..."
cd terraform/

terraform init
echo ""
echo "WARNING: This will destroy all resources created by Terraform!"
echo ""
terraform destroy -auto-approve

echo ""
echo "========================================="
echo "EKS Cluster Destruction Complete!"
echo "========================================="
echo ""
echo "All resources have been cleaned up."
