provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "tf_backend"
    storage_account_name = "terraformstate01azuretks"
    container_name       = "tfbackend-prod"
    key                  = "terraform.tfstate"
  }
}