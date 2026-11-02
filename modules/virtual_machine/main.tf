resource "azurerm_linux_virtual_machine" "vm" {
  for_each                        = var.linux_vms
  name                            = each.value.name
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  size                            = try(each.value.size, "Standard_B1s")
  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
  disable_password_authentication = false
  network_interface_ids           = each.value.network_interface_ids

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = try(each.value.os_disk_type, "Standard_LRS")
  }

  source_image_reference {
    publisher = try(each.value.image_publisher, "Canonical")
    offer     = try(each.value.image_offer, "0001-com-ubuntu-server-jammy")
    sku       = try(each.value.image_sku, "22_04-lts-gen2")
    version   = try(each.value.image_version, "latest")
  }

  tags = try(each.value.tags, {})
}
