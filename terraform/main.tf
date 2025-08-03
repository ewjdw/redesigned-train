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
