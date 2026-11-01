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
  description = "Private IP of the Storage Account Private Endpoint in Hub VNet"
  value       = azurerm_private_endpoint.storage_pe.private_service_connection[0].private_ip_address
}

output "vm_public_ip" {
  description = "Public IP of the testing VM"
  value       = azurerm_public_ip.vm_pip.ip_address
}

output "vm_private_ip" {
  description = "Private IP of the VM inside Spoke VNet"
  value       = azurerm_network_interface.vm_nic.private_ip_address
}

output "ssh_command" {
  description = "SSH Command to connect to the test VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.vm_pip.ip_address}"
}

