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

# Generate S3 bucket name (must match start.sh)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="eks-tfstate-${AWS_ACCOUNT_ID}"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"

terraform init \
    -backend-config="bucket=$BUCKET_NAME" \
    -backend-config="region=$REGION"
echo ""
echo "WARNING: This will destroy all resources created by Terraform!"
echo ""
terraform destroy -auto-approve

# Step 4: Cleanup IAM resources created outside Terraform
echo ""
echo "Step 4: Cleaning up IAM resources..."

# Detach policy from AmazonEKS_EBS_CSI_Driver role
echo "Detaching policy from AmazonEKS_EBS_CSI_Driver role..."
aws iam detach-role-policy \
    --role-name AmazonEKS_EBS_CSI_Driver \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    2>/dev/null && echo "✅ Policy detached" || echo "ℹ️  Policy not attached or role doesn't exist"

# Delete AmazonEKS_EBS_CSI_Driver role
echo "Deleting AmazonEKS_EBS_CSI_Driver role..."
aws iam delete-role \
    --role-name AmazonEKS_EBS_CSI_Driver \
    2>/dev/null && echo "✅ Role deleted" || echo "ℹ️  Role doesn't exist"

# Clean up temporary files
rm -f trust-policy.json aws-auth-cm.yaml 2>/dev/null

echo "IAM cleanup complete."

echo ""
echo "========================================="
echo "EKS Cluster Destruction Complete!"
echo "========================================="
echo ""
echo "All resources have been cleaned up."
