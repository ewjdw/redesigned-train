resource "azurerm_service_plan" "rtrain_service_plan" {
  name                = "asp-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type = "Linux"
  sku_name = var.sku_name
  
  tags = var.tags 
  
}

resource "azurerm_app_service" "rtrain_app_service" {
  name                = "app-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_service_plan.rtrain_service_plan.id
  
  site_config {
    linux_fx_version = "DOCKER|${var.acr_login_server}/rtrainapp:${var.workload}-${var.environment}"
  }

  app_settings = {
    "ConnectionStrings__DefaultConnection" = "Server=tcp:${var.sql_server_fqdn},1433;Initial Catalog=${var.sql_database_name};Authentication=Active Directory Managed Identity;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
    DOCKER_REGISTRY_SERVER_URL = "https://${var.acr_login_server}"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}