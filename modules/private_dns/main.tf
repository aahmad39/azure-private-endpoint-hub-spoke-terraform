resource "azurerm_private_dns_zone" "this" {
  for_each            = var.dns_zones
  name                = each.value.name
  resource_group_name = each.value.rg_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each              = var.dns_links
  name                  = each.value.name
  resource_group_name   = each.value.rg_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.dns_zone_key].name
  virtual_network_id    = each.value.vnet_id
}
