provider "azurerm" {
  features {}
}

terraform {
    required_version = ">=1.9"

    required_providers {
      azurerm = {
        source  = "hashicorp/azurerm"
        version = "4.21.0"
      }
    }


  backend "azurerm" {
    resource_group_name  = "tf_backend"
    storage_account_name = "terraformstate01azuretks"
    container_name       = "tfbackend-dev"
    key                  = "terraform.tfstate"
  }
}