# Azure Credentials Setup Guide

This guide explains how to obtain Azure **Service Principal** credentials for deploying AKS clusters.

## Prerequisites

- Active Azure subscription
- Access to Azure Portal or Azure CLI
- Owner or Contributor role on the subscription

---

## Using Azure Portal (UI)

### Step 1: Register an Application

1. Sign in to [Azure Portal](https://portal.azure.com/)
2. Search for **"Azure Active Directory"** or **"Microsoft Entra ID"**
3. Click **App registrations** in the left sidebar
4. Click **+ New registration**
5. Fill in details:
   - **Name**: `aks-deployer`
   - **Supported account types**: "Accounts in this organizational directory only"
   - **Redirect URI**: Leave blank
6. Click **Register**

### Step 2: Note the Application (Client) ID and Tenant ID

7. On the app overview page, copy:
   - **Application (client) ID**: `12345678-1234-1234-1234-123456789abc`
   - **Directory (tenant) ID**: `87654321-4321-4321-4321-cba987654321`

### Step 3: Create a Client Secret

8. Click **Certificates & secrets** in the left sidebar
9. Click **+ New client secret**
10. Add description: `eks-deployer-secret`
11. Select expiration: **730 days (24 months)** (recommended)
12. Click **Add**
13. **IMPORTANT**: Copy the **Value** immediately (it won't be shown again!)
    - Secret Value: `dGhpc2lzYXNlY3JldGV4YW1wbGU=`

### Step 4: Assign Required Roles

14. Go to **Subscriptions** (search in top bar)
15. Click on your subscription
16. Click **Access control (IAM)** in the left sidebar
17. Click **+ Add** → **Add role assignment**
18. Add the following roles (repeat for each):
    - **Contributor** - Required for creating AKS clusters and related resources
    - **Storage Account Contributor** - Required for Terraform state storage
19. For each role:
    - Search for the role name
    - Click **Next**
    - Click **+ Select members**
    - Search for `aks-deployer` (your app name)
    - Click **Select**
    - Click **Review + assign**

**Note**: The Storage Account Contributor role is needed because Terraform state is stored in an Azure Storage Account for persistence across GitHub Actions workflow runs.


## Required Credentials

For **easy-k8s-deploy**, you need:

| Credential | Description | Example |
|------------|-------------|---------|
| **Azure Client ID** | Application (client) ID from app registration | `12345678-1234-1234-1234-123456789abc` |
| **Azure Client Secret** | Secret value (password) | `dGhpc2lzYXNlY3JldGV4YW1wbGU=` |
| **Azure Tenant ID** | Directory (tenant) ID | `87654321-4321-4321-4321-cba987654321` |

---

## Using Credentials

### Method A: Paste in Workflow Dispatch

1. Go to GitHub Actions → **Deploy AKS Cluster**
2. Click **Run workflow**
3. Paste credentials:
   - **Azure Client ID**: `12345678-1234-1234-1234-123456789abc`
   - **Azure Client Secret**: `dGhpc2lzYXNlY3JldGV4YW1wbGU=`
   - **Azure Tenant ID**: `87654321-4321-4321-4321-cba987654321`
4. Click **Run workflow**

### Method B: Save as GitHub Secrets (Recommended)

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Click **New repository secret**
4. Add three secrets:
   - Name: `AZURE_CLIENT_ID`
     Value: `12345678-1234-1234-1234-123456789abc`
   - Name: `AZURE_CLIENT_SECRET`
     Value: `dGhpc2lzYXNlY3JldGV4YW1wbGU=`
   - Name: `AZURE_TENANT_ID`
     Value: `87654321-4321-4321-4321-cba987654321`
5. Go to Actions → **Deploy AKS Cluster**
6. Click **Run workflow** (leave fields empty)
7. Credentials are automatically used from secrets

---
