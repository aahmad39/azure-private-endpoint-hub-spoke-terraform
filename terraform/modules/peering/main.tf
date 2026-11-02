resource "azurerm_virtual_network_peering" "peering1" {
  name                         = var.peering1_name
  resource_group_name          = var.vnet1_resource_group_name
  virtual_network_name         = var.vnet1_name
  remote_virtual_network_id    = var.vnet2_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "peering2" {
  name                         = var.peering2_name
  resource_group_name          = var.vnet2_resource_group_name
  virtual_network_name         = var.vnet2_name
  remote_virtual_network_id    = var.vnet1_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
