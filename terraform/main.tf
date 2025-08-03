locals {
  tags = {
    environment  = var.environment
    subscription = var.subscription_id
  }
}

resource "azurerm_resource_group" "rtrain_rg" {
  name = "rg-${var.workload}-${var.environment}"
  location = var.location

  tags = local.tags
}

resource "azurerm_container_registry" "rtrain_acr" {
  name                = "acr${var.workload}${var.environment}"
  resource_group_name = azurerm_resource_group.rtrain_rg.name
  location            = azurerm_resource_group.rtrain_rg.location
  sku                 = var.acr_sku
  admin_enabled       = false

  tags = merge(local.tags, {
    workload = var.workload
  })
  
}

module "sql" {
  source = "./modules/sql"
  environment = var.environment
  location = var.location
  workload = var.workload
  resource_group_name = azurerm_resource_group.rtrain_rg.name
  sql_server_name = "sql${var.workload}${var.environment}"
  administrator_login = var.sql_admin_login
  administrator_password = var.sql_admin_password
  database_sku_name = var.sql_config.database_sku_name
  storage_account_type = var.sql_config.storage_account_type
  tags = local.tags
}
