terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }

  backend "azurerm" {
    # Storage account name, container name, and key provided via -backend-config
    # Example: terraform init -backend-config="storage_account_name=akstfstate..." -backend-config="container_name=tfstate" -backend-config="key=aks.tfstate"
  }
}

provider "azurerm" {
  subscription_id = data.external.environment.result["subscription_id"]
  tenant_id       = data.external.environment.result["tenant_id"]
  client_id       = data.external.environment.result["client_id"]
  client_secret   = data.external.environment.result["client_secret"]

  resource_provider_registrations = "none"

  features {}
}
