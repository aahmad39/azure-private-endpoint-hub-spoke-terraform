resource "azurerm_virtual_network_peering" "this" {
  for_each                     = var.peering
  name                         = each.value.name
  resource_group_name          = each.value.rg_name
  virtual_network_name         = each.value.vnet_name
  remote_virtual_network_id    = each.value.remote_vnet_id
  allow_virtual_network_access = try(each.value.allow_virtual_network_access, true)
  allow_forwarded_traffic      = try(each.value.allow_forwarded_traffic, true)
}
