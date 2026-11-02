resource "azurerm_network_interface" "nic" {
  for_each            = var.vms
  name                = each.value.nic_name
  location            = each.value.location
  resource_group_name = each.value.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = try(each.value.private_ip, "Dynamic")
    public_ip_address_id          = try(each.value.pip_id, null)
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  for_each = {
    for k, v in var.vms : k => v
    if try(v.nsg_id, null) != null
  }
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = each.value.nsg_id
}

resource "azurerm_linux_virtual_machine" "main" {
  for_each                        = var.vms
  name                            = each.value.name
  location                        = each.value.location
  resource_group_name             = each.value.rg_name
  network_interface_ids           = [azurerm_network_interface.nic[each.key].id]
  size                            = try(each.value.vm_size, "Standard_B1s")
  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
  disable_password_authentication = false

  os_disk {
    name                 = try(each.value.os_disk_name, "${each.value.name}-osdisk")
    caching              = "ReadWrite"
    storage_account_type = try(each.value.managed_disk_type, "Standard_LRS")
  }

  source_image_reference {
    publisher = try(each.value.publisher, "Canonical")
    offer     = try(each.value.offer, "0001-com-ubuntu-server-jammy")
    sku       = try(each.value.sku, "22_04-lts-gen2")
    version   = try(each.value.version, "latest")
  }
}
