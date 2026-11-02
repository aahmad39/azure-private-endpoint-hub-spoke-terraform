data "azurerm_virtual_network" "vnet2" {
  for_each            = var.peering
  name                = each.value.remote_vnet_name
  resource_group_name = each.value.remote_rg_name
}

resource "azurerm_virtual_network_peering" "this" {
  for_each                     = var.peering
  name                         = each.value.name
  resource_group_name          = each.value.rg_name
  virtual_network_name         = each.value.vnet_name
  remote_virtual_network_id    = data.azurerm_virtual_network.vnet2[each.key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
