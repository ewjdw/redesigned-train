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
  display_name = var.spn.display_name
  object_id = var.spn.object_id
  database_sku_name = var.db_config.database_sku_name
  storage_account_type = var.db_config.storage_account_type
  tags = local.tags
}

module "appservice" {
  source = "./modules/appservice"
  environment = var.environment
  location = var.location
  workload = var.workload
  resource_group_name = azurerm_resource_group.rtrain_rg.name
  acr_login_server = azurerm_container_registry.rtrain_acr.login_server
  sql_server_fqdn = module.sql.fqdn
  sql_database_name = module.sql.database_name
  sku_name = var.app_service_plan_sku_name
  tags = local.tags  
}

resource "azurerm_role_assignment" "appservice_acr_pull" {
  scope                = azurerm_container_registry.rtrain_acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.appservice.app_service_principal_id
  
}
