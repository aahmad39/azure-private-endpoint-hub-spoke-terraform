resource "azurerm_network_interface" "nic" {
  for_each            = var.network_interfaces
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  tags                = try(each.value.tags, {})

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = try(each.value.private_ip_address_allocation, "Dynamic")
    public_ip_address_id          = try(each.value.public_ip_address_id, null)
  }
}

resource "azurerm_network_interface_security_group_association" "assoc" {
  for_each = {
    for k, v in var.network_interfaces : k => v
    if v.nsg_id != null
  }
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = each.value.nsg_id
}
