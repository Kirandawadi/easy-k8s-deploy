# GCP Credentials Setup Guide

This guide explains how to obtain GCP **Service Account** credentials for deploying GKE clusters.

## Using GCP Console (UI)

### Step 1: Navigate to Service Accounts

1. Sign in to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project from the dropdown at the top
3. Navigate to **IAM & Admin** → **Service Accounts**
   - Or search for "Service Accounts" in the top search bar
4. Click **+ CREATE SERVICE ACCOUNT**


### Step 2: Create Service Account

5. Fill in details:
   - **Service account name**: `gke-deployer`
   - **Service account ID**: `gke-deployer` (auto-filled)
   - **Description**: "Service account for GKE cluster deployment"
6. Click **CREATE AND CONTINUE**

### Step 3: Grant Roles

7. Click **Select a role** dropdown
8. Add the following roles (click "+ ADD ANOTHER ROLE" for each):
   - **Kubernetes Engine Admin** (`roles/container.admin`)
   - **Compute Instance Admin (v1)** (`roles/compute.instanceAdmin.v1`)
   - **Compute Network User** (`roles/compute.networkUser`)
   - **Service Account User** (`roles/iam.serviceAccountUser`)
   - **Storage Admin** (`roles/storage.admin`)
9. Click **CONTINUE**
10. Click **DONE**

![GCP Service Account](../attachments/GCP-Service-Account.png)

### Step 4: Create Key

11. Click on the newly created service account email
12. Go to **KEYS** tab
13. Click **ADD KEY** → **Create new key**
14. Select **JSON** format
15. Click **CREATE**
16. A JSON file will be downloaded (e.g., `gke-deployer-abc123.json`)

### Step 5: Extract Credentials

Open the downloaded JSON file. You'll see something like this:

```json
{
  "type": "service_account",
  "project_id": "my-project-123456",
  "private_key_id": "abc123def456...",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBg...\n-----END PRIVATE KEY-----\n",
  "client_email": "gke-deployer@my-project-123456.iam.gserviceaccount.com",
  "client_id": "123456789012345678901",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  ...
}
```

**Extract these 3 values:**

1. **Project ID**: `my-project-123456` (from `project_id` field)
2. **Service Account Email**: `gke-deployer@my-project-123456.iam.gserviceaccount.com` (from `client_email` field)
3. **Private Key**: The entire multi-line string from `private_key` field (including BEGIN/END lines)

## Using Credentials

### Method A: Paste in Workflow Dispatch

1. Go to GitHub Actions → **Deploy GKE Cluster**
2. Click **Run workflow**
3. Paste credentials:
   - **GCP Project ID**: `my-project-123456`
   - **Service Account Email**: `gke-deployer@my-project-123456.iam.gserviceaccount.com`
   - **Service Account Private Key**:
     ```
     -----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBg...\n-----END PRIVATE KEY-----\n
     ```
4. Click **Run workflow**

### Method B: Save as GitHub Secrets (Recommended)

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Click **New repository secret**
4. Add three secrets:
   - Name: `GOOGLE_PROJECT_ID`
     Value: `my-project-123456`
   - Name: `GOOGLE_SERVICE_ACCOUNT_EMAIL`
     Value: `gke-deployer@my-project-123456.iam.gserviceaccount.com`
   - Name: `GOOGLE_PRIVATE_KEY`
     Value: (paste entire private key with BEGIN/END lines)
5. Go to Actions → **Deploy GKE Cluster**
6. Click **Run workflow** (leave fields empty)
7. Credentials are automatically used from secrets