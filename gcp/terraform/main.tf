terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    # Bucket name is provided dynamically via: terraform init -backend-config="bucket=gke-tfstate-PROJECT_ID"
    prefix = "terraform/state"
  }
}

provider "google" {
  credentials = data.external.environment.result["credentials"]
  project     = data.external.environment.result["project_id"]
  region      = var.region
}
