# AWS Credentials Setup Guide

This guide explains how to obtain AWS credentials with **AdministratorAccess** for deploying EKS clusters.

## Prerequisites

- Active AWS account
- Access to AWS Management Console or AWS CLI

## Using AWS Management Console (UI)

### Step 1: Create IAM User

1. Sign in to [AWS Management Console](https://console.aws.amazon.com/)
2. Navigate to **IAM** (Identity and Access Management)
   - Search for "IAM" in the top search bar
3. Click **Users** in the left sidebar
4. Click **Create user** button

### Step 2: Configure User Details

5. **User name**: Enter a name (e.g., `eks-deployer`)
6. Check **"Provide user access to AWS Management Console"** if you want console access (optional)
7. Click **Next**

### Step 3: Attach Policies

8. Select **"Attach policies directly"**
9. Search for `AdministratorAccess`
10. Check the box next to **AdministratorAccess** policy
11. Click **Next**
12. Review and click **Create user**

### Step 4: Generate Access Keys

13. Click on the newly created user
14. Go to **"Security credentials"** tab
15. Scroll down to **"Access keys"** section
16. Click **"Create access key"**
17. Select **"Command Line Interface (CLI)"**
18. Check the confirmation box
19. Click **Next**
20. (Optional) Add description tag
21. Click **Create access key**

### Step 5: Save Credentials

**IMPORTANT**: Save these credentials immediately - they won't be shown again!

22. Copy **Access key ID** (e.g., `AKIAIOSFODNN7EXAMPLE`)
23. Copy **Secret access key** (e.g., `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`)
24. Click **Done**

---

## Required Credentials

For **easy-k8s-deploy**, you need:

| Credential | Description | Example |
|------------|-------------|---------|
| **AWS Access Key ID** | Public identifier for your IAM user | `AKIAIOSFODNN7EXAMPLE` |
| **AWS Secret Access Key** | Secret key for authentication | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |

---

## Using Credentials

### Method A: Paste in Workflow Dispatch

1. Go to GitHub Actions → **Deploy EKS Cluster**
2. Click **Run workflow**
3. Paste credentials:
   - **AWS Access Key**: `AKIAIOSFODNN7EXAMPLE`
   - **AWS Secret Access Key**: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`
4. Click **Run workflow**

### Method B: Save as GitHub Secrets (Recommended)

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Click **New repository secret**
4. Add two secrets:
   - Name: `AWS_ACCESS_KEY_ID`
     Value: `AKIAIOSFODNN7EXAMPLE`
   - Name: `AWS_SECRET_ACCESS_KEY`
     Value: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`
5. Go to Actions → **Deploy EKS Cluster**
6. Click **Run workflow** (leave fields empty)
7. Credentials are automatically used from secrets