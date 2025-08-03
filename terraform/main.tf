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
  principal_id         = module.appservice.appservice_principal_id
  
}

resource "null_resource" "sql_add_ad_user" {
  depends_on = [module.sql, module.appservice]
  
  provisioner "local-exec" {
    command = <<EOT
      az sql db user create \
      --resource-group ${azurerm_resource_group.rtrain_rg.name} \
      --server ${module.sql.sql_server_name} \
      --display-name "${module.appservice.app_service_name}" \
      --object-id ${module.appservice.app_service_principal_id} \
      --role db_datareader,db_datawriter
    EOT
    environment = {
      SQL_ADMIN_LOGIN = var.sql_admin_login
      SQL_ADMIN_PASSWORD = var.sql_admin_password
      AZURE_SUBSCRIPTION_ID = var.subscription_id
      AZURE_TENANT_ID = var.azure_tenant_id
    }
  }
  
  triggers = {
    sql_server_name = module.sql.sql_server_name
  }
  
}
