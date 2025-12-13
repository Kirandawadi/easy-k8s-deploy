![Mascot](attachments/mascot.png)

# easy-k8s-deploy

One-click Kubernetes cluster deployment across AWS, Azure, and GCP using GitHub Actions.

Deploy PoC Kubernetes clusters to any cloud provider with a single workflow dispatch. No local setup required - everything runs in GitHub Actions!

> I personally use this repo to deploy test clusters to temporary cloud environments like KodeKloud.
> I do not recommend using this repo for production environments.

---

## Features

- **Multi-Cloud Support**: Deploy to AWS EKS, Azure AKS, or GCP GKE
- **Flexible Authentication**: Use workflow inputs OR GitHub Secrets
- **Fully Automated**: Complete deployment via GitHub Actions
- **Easy Cleanup**: One-click cluster destruction
- **Cost-Optimized**: Reasonable defaults for demo/dev clusters
- **Comprehensive Docs**: Step-by-step credential setup guides

---

## What Gets Deployed

### AWS EKS
- **Cluster**: EKS control plane in us-east-1
- **Nodes**: 2x c7i-flex.large EC2 instances (Auto Scaling Group: min 1, max 3)
- **Networking**: Default VPC with public subnets across 3 availability zones
- **Storage**: Terraform state stored in S3 bucket
- **IAM**: Custom roles for cluster and node instances

### Azure AKS
- **Cluster**: AKS control plane (Free tier)
- **Nodes**: 2x Standard_D2s_v3 VMs (system node pool)
- **Networking**: Azure-managed networking (single availability zone)
- **Storage**: Terraform state stored in Azure Storage Account
- **Identity**: System-assigned managed identity

### GCP GKE
- **Cluster**: GKE cluster in us-central1
- **Nodes**: 2x e2-medium VMs (managed node pool)
- **Networking**: VPC-native with Workload Identity
- **Storage**: Terraform state stored in GCS bucket
- **Security**: Shielded instances with secure boot and integrity monitoring

---

## Quick Start

### Prerequisites

1. GitHub account
2. Cloud provider account (AWS, Azure, or GCP)
3. 5 minutes to set up credentials

### Step 1: Get Cloud Credentials

Choose your cloud provider and follow the credential setup guide:

| Cloud | Guide | What You Need |
|-------|-------|---------------|
| **AWS** | [aws/README.md](aws/README.md) | Access Key ID + Secret Key |
| **Azure** | [azure/README.md](azure/README.md) | Client ID + Client Secret + Tenant ID |
| **GCP** | [gcp/README.md](gcp/README.md) | Project ID + Service Account Email + Private Key |

### Step 2: Choose Authentication Method

#### Option A: GitHub Secrets (Recommended)

1. Go to your repo: **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add secrets based on your cloud provider:

**For AWS:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**For Azure:**
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`

**For GCP:**
- `GOOGLE_PROJECT_ID`
- `GOOGLE_SERVICE_ACCOUNT_EMAIL`
- `GOOGLE_PRIVATE_KEY`

#### Option B: Workflow Dispatch Inputs

No setup needed - just paste credentials when running the workflow!

> **⚠️ SECURITY WARNING ⚠️**
>
> Even though the workflow dispatch inputs has been masked and it won't be visible in the workflow run logs, this is still not a good practice.
> The recommended approach is to use the GitHub Secrets method.
>
> Only use this method if your repository is **PRIVATE**.


### Step 3: Deploy Cluster

1. Go to **Actions** tab
2. Select deployment workflow:
   - **Deploy EKS Cluster** (AWS)
   - **Deploy AKS Cluster** (Azure)
   - **Deploy GKE Cluster** (GCP)
3. Click **Run workflow**
4. **If using secrets**: Leave all fields empty → Click **Run workflow**
5. **If using inputs**: Paste your credentials → Click **Run workflow**
6. Wait 10-15 minutes for deployment
7. ✅ Cluster ready!

### Step 4: Access Your Cluster

After deployment completes, check the workflow logs for access commands:

**AWS:**
```bash
aws eks update-kubeconfig --region us-east-1 --name demo-eks
kubectl get nodes
```

**Azure:**
```bash
az aks get-credentials --resource-group <rg-name> --name demo-aks --overwrite-existing
kubectl get nodes
```

**GCP:**
```bash
gcloud container clusters get-credentials demo-gke --region us-west1 --project <project-id>
kubectl get nodes
```

---

## Destroying Clusters

### One-Click Cleanup

1. Go to **Actions** tab
2. Select destroy workflow:
   - **Destroy EKS Cluster** (AWS)
   - **Destroy AKS Cluster** (Azure)
   - **Destroy GKE Cluster** (GCP)
3. Click **Run workflow**
4. Provide same credentials used for deployment
5. Click **Run workflow**
6. All resources cleaned up!