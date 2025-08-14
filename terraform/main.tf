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
  name                          = "acr${var.workload}${var.environment}"
  resource_group_name           = azurerm_resource_group.rtrain_rg.name
  location                      = azurerm_resource_group.rtrain_rg.location
  sku                           = var.acr_sku
  admin_enabled                 = false
  public_network_access_enabled = false

  tags = merge(local.tags, {
    workload = var.workload
  })
  
}

resource "azurerm_private_endpoint" "acr_pep" {

  name                = "pep-${azurerm_container_registry.acr.name}"
  resource_group_name = azurerm_resource_group.rtrain_rg.name
  location            = azurerm_resource_group.rtrain_rg.location

  subnet_id = azurerm_subnet.subnet["snet-${var.workload}-${var.environment}-data"].id

  private_service_connection {
    name                           = "pep-${azurerm_container_registry.acr.name}"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = data.azurerm_private_dns_zone.dns_zone["acr"].name
    private_dns_zone_ids = [data.azurerm_private_dns_zone.dns_zone["acr"].id]
  }
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
  subnet_id = azurerm_subnet.subnet["snet-${var.workload}-${var.environment}-data"].id
  dns_zone_id = data.azurerm_private_dns_zone.dns_zone["sql-database"].id
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
  subnet_id = azurerm_subnet.subnet["snet-${var.workload}-${var.environment}-data"].id
  app_dns_zone_id = data.azurerm_private_dns_zone.dns_zone["app-service"].id
  scm_dns_zone_id = data.azurerm_private_dns_zone.dns_zone["scm-app-service"].id
  tags = local.tags  
}

resource "azurerm_role_assignment" "appservice_acr_pull" {
  scope                = azurerm_container_registry.rtrain_acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.appservice.app_service_principal_id
  
}

resource "azurerm_role_assignment" "spn_acr_push" {
  scope                = azurerm_container_registry.rtrain_acr.id
  role_definition_name = "AcrPush"
  principal_id         = var.spn.object_id
  
}
