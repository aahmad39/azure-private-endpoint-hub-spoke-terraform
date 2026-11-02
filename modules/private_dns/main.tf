resource "azurerm_private_dns_zone" "dns_zone" {
  for_each            = var.dns_zones
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  tags                = try(each.value.tags, {})
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  for_each              = var.vnet_links
  name                  = each.value.name
  resource_group_name   = each.value.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone[each.value.dns_zone_key].name
  virtual_network_id    = each.value.virtual_network_id
}
