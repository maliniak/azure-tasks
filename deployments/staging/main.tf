module "azure_app" {
    source = "../../aplications/web_app"
    environment = "staging"
    mysql_sku_name       = "B_Standard_B1s"
    mysql_storage_size   = 20
    backup_retention_days = 7
    app_service_sku      = "B1"
    docker_image         = "my-nodejs-app:latest"
    docker_registry_url  = "https://index.docker.io/v1/"
    vnet_address_space = "10.3.0.0/16"
    subnet_address_prefix = "10.3.1.0/24"
}