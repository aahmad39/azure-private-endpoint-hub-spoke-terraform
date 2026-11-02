data "azurerm_virtual_network" "vnet" {
  for_each            = var.dns_links
  name                = each.value.vnet_name
  resource_group_name = each.value.rg_name
}

resource "azurerm_private_dns_zone" "this" {
  for_each            = var.dns_zones
  name                = each.value.name
  resource_group_name = each.value.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = var.dns_links
  name                  = each.value.name
  resource_group_name   = each.value.rg_name
  private_dns_zone_name = each.value.dns_zone_name
  virtual_network_id    = data.azurerm_virtual_network.vnet[each.key].id

  depends_on = [azurerm_private_dns_zone.this]
}
