locals {
  tags = merge(var.tags, {
    workload = var.workload
  })
}

resource "azurerm_mssql_server" "rtrain_sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"

  azuread_administrator {
    login_username              = var.display_name
    object_id                   = var.object_id
    azuread_authentication_only = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
  
}

resource "azurerm_private_endpoint" "sql_pep" {
  name                = "pep-${azurerm_mssql_server.rtrain_sql_server.name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  subnet_id = var.subnet_id

  private_service_connection {
    name                           = "pep-${azurerm_mssql_server.rtrain_sql_server.name}"
    private_connection_resource_id = azurerm_mssql_server.rtrain_sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = var.dns_zone_name 
    private_dns_zone_ids = [var.dns_zone_id]
  }
}

resource "azuread_directory_role_assignment" "sql_directory_reader" {
  role_id = "88d8e3e3-8f55-4a1e-953a-9b9898b8876b" # Directory Readers
  principal_object_id = azurerm_mssql_server.rtrain_sql_server.identity[0].principal_id

}

resource "azurerm_mssql_database" "rtrain_sql_database" {
  name                 = "db-${var.workload}-${var.environment}"
  server_id            = azurerm_mssql_server.rtrain_sql_server.id
  sku_name             = var.database_sku_name
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  storage_account_type = var.storage_account_type

  tags = local.tags

}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name                = "AllowAzureServices"
  server_id           = azurerm_mssql_server.rtrain_sql_server.id
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
  
}
