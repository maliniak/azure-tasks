provider "azurerm" {
  features {}
  subscription_id = ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  client_id       = ${{ secrets.AZURE_CLIENT_ID }}
  client_secret   = ${{ secrets.AZURE_CLIENT_SECRET }}
  tenant_id       = ${{ secrets.AZURE_TENANT_ID }}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "tf_backend"
    storage_account_name = "terraformstate01azuretks"
    container_name       = "tfbackend-dev"
    key                  = "terraform.tfstate"
  }
}