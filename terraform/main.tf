resource "azurerm_resource_group" "lpotato_rg" {
  name = "rg-${var.workload}-${var.environment}"
  location = var.location
}
