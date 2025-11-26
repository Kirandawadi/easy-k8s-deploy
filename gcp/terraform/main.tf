terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  credentials = data.external.environment.result["credentials"]
  project     = data.external.environment.result["project_id"]
  region      = var.region
}
