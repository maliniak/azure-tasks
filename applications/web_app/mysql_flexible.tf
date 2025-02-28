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
  name                   = "${var.environment}-mysql-server-azure-task"
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
  #delegated_subnet_id = azurerm_subnet.app_subnet.id
  private_dns_zone_id = azurerm_private_dns_zone.dns_zone.id
  #public_network_access_enabled = false

  depends_on = [azurerm_private_dns_zone_virtual_network_link.dns_link]
    lifecycle {
      ignore_changes = [
        private_dns_zone_id
      ]
    }

}

resource "azurerm_private_endpoint" "mysql_endpoint" {
  name                = "${var.environment}-mysql-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoint_subnet.id

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

  lifecycle {
    ignore_changes = [
      private_service_connection
    ]
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
  name                = "${var.environment}-nodejs-app-azure-task"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.app_plan.id

  site_config {
    always_on = true
    container_registry_use_managed_identity = true
  }


  app_settings = {
    "DB_HOST"     = azurerm_mysql_flexible_server.mysql.fqdn
    "DB_USER"     = var.db_admin_username
    "DB_PASSWORD" = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault_secret.mysql_password.id})"
    "DB_NAME"     = "mydb"
  }
  logs {
    application_logs {
          file_system_level = "Verbose"
    }
    detailed_error_messages = true
  }

  identity {
    type = "SystemAssigned"
  }

   lifecycle {
     ignore_changes = [
       app_settings
     ]
   }

  virtual_network_subnet_id = azurerm_subnet.app_subnet.id
}

resource "azurerm_key_vault_access_policy" "app_policy" {
  #depends_on = [azurerm_linux_web_app.app]

  key_vault_id = data.azurerm_key_vault.shared_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_web_app.app.identity[0].principal_id

  secret_permissions = ["Get"]
}