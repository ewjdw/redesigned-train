resource "azurerm_service_plan" "rtrain_service_plan" {
  name                = "asp-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name
  
  tags = var.tags 
  
}

resource "azurerm_linux_web_app" "rtrain_app_service" {
  name                = "app-${var.workload}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id = azurerm_service_plan.rtrain_service_plan.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    container_registry_use_managed_identity = true
    
    application_stack {
      docker_image_name   = "${var.acr_login_server}/${var.workload}-${var.environment}:latest"
      docker_registry_url = "https://${var.acr_login_server}"
    }
  }

  app_settings = {
    "ConnectionStrings__DefaultConnection" = "Server=tcp:${var.sql_server_fqdn},1433;Initial Catalog=${var.sql_database_name};Authentication=Active Directory Managed Identity;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "app_pep" {
  name                = "pep-${azurerm_linux_web_app.rtrain_app_service.name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id = var.subnet_id

  private_service_connection {
    name                           = "pep-${azurerm_linux_web_app.rtrain_app_service.name}"
    private_connection_resource_id = azurerm_linux_web_app.rtrain_app_service.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = var.app_dns_zone_name
    private_dns_zone_ids = [var.app_dns_zone_id]
  }
}

resource "azurerm_private_endpoint" "app_scm_pep" {
  name                = "pep-${azurerm_linux_web_app.rtrain_app_service.name}-scm"
  location            = var.location
  resource_group_name = var.resource_group_name

  subnet_id = var.subnet_id

  private_service_connection {
    name                           = "pep-${azurerm_linux_web_app.rtrain_app_service.name}-scm"
    private_connection_resource_id = azurerm_linux_web_app.rtrain_app_service.id
    subresource_names              = ["scm"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = var.scm_dns_zone_name
    private_dns_zone_ids = [var.scm_dns_zone_id]
  }
}
