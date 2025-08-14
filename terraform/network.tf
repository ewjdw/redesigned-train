locals {
  private_dns_zones = {
    app-service = "privatelink.azurewebsites.net"
    scm-app-service = "scm.privatelink.azurewebsites.net"
    sql-database  = "privatelink.database.windows.net"
    acr           = "privatelink.azurecr.io"
  }

}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.workload}-${var.environment}"
  address_space       = [var.vnet_range]
  location            = azurerm_resource_group.rtrain_rg.location
  resource_group_name = azurerm_resource_group.rtrain_rg.name
}

module "subnets" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = azurerm_virtual_network.vnet.address_space[0]
  networks = [
      {
        name     = "snet-${var.workload}-${var.environment}-app-integration"
        new_bits = 3
      },
      {
        name     = "snet-${var.workload}-${var.environment}-data"
        new_bits = 3
      },
    ]
}

resource "azurerm_subnet" "subnet" {

  for_each = module.subnets.network_cidr_blocks

  name                              = each.key
  resource_group_name               = azurerm_resource_group.rtrain_rg.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = [each.value]
  private_endpoint_network_policies = strcontains(each.key, "app-integration") ? false : true

  dynamic "delegation" {
    for_each = strcontains(each.key, "app-integration") ? [1] : []

    content {
      name = "app-integration-tier-delegation"

      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}

resource "azurerm_private_dns_zone" "dns_zone" {
  for_each = local.private_dns_zones

  name                = each.value
  resource_group_name = azurerm_resource_group.rtrain_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_vnet_link" {
  for_each = local.private_dns_zones

  name                  = "${var.workload}-${var.environment}-${each.key}"
  resource_group_name   = azurerm_resource_group.rtrain_rg.name
  private_dns_zone_name = each.value
  virtual_network_id    = azurerm_virtual_network.vnet.id

  depends_on = [data.azurerm_private_dns_zone.dns_zone]
}
