output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "storage_account_blob_endpoint" {
  value = azurerm_storage_account.sa.primary_blob_endpoint
}

output "private_endpoint_ip" {
  value = azurerm_private_endpoint.pe.private_service_connection[0].private_ip_address
}

output "vm_public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "vm_private_ip" {
  value = azurerm_network_interface.nic.private_ip_address
}

output "ssh_command" {
  value = "ssh ${var.vm_config.admin_username}@${azurerm_public_ip.pip.ip_address}"
}
