terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.33.0"
    }
  }
backend "azurerm" {
    # resource_group_name  = "Agent-RG"
    # storage_account_name = "agentstorage12"
    # container_name       = "tfstate"
    # key                  = "aks.tfstate"
  }
}

provider "azurerm" {
  # Configuration options
  features {

  }
  # subscription_id = "9c2d44b8-0b58-4481-8de2-41223a92f641"
}
