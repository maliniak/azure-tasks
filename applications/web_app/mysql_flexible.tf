resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-app-rg"
  location = "polandcentral"
}

data "azurerm_key_vault" "shared_kv" {
  name                = "${var.environment}-web-app-kv"
  resource_group_name = "${var.environment}-shared-rg"
}

data "azurerm_key_vault_secret" "mysql_password" {
  name         = "mysqlpassword"
  key_vault_id = data.azurerm_key_vault.shared_kv.id
}

data "azurerm_client_config" "current" {}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${var.environment}-mysql-server"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = "adminuser"
  administrator_password = data.azurerm_key_vault_secret.mysql_password.value
  sku_name               = var.mysql_sku_name
  version                = "8.0.21"
  storage {
    size_gb = 20
  }
  backup_retention_days = 7
}

resource "azurerm_private_endpoint" "mysql_endpoint" {
  name                = "${var.environment}-mysql-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet.id

  private_service_connection {
    name                           = "mysql-connection"
    private_connection_resource_id = azurerm_mysql_flexible_server.mysql.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "mysql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone.id]
  }
}

resource "azurerm_service_plan" "app_plan" {
  name                = "${var.environment}-app-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = var.app_service_sku
}

resource "azurerm_linux_web_app" "app" {
  name                = "${var.environment}-nodejs-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
  app_settings = {
    "DB_HOST"     = azurerm_mysql_flexible_server.mysql.fqdn
    "DB_USER"     = var.db_admin_username
    "DB_PASSWORD" = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault_secret.mysql_password.id})"
    "DB_NAME"     = "mydb"
  }

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = azurerm_subnet.subnet.id
}

resource "azurerm_key_vault_access_policy" "app_policy" {
  #depends_on = [azurerm_linux_web_app.app]

  key_vault_id = data.azurerm_key_vault.shared_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.app.identity[0].principal_id

  secret_permissions = ["Get"]
}