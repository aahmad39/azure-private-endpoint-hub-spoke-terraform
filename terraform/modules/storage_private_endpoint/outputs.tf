output "storage_account_id" {
  value = azurerm_storage_account.sa.id
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.sa.primary_blob_endpoint
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.pe.id
}

output "private_endpoint_ip" {
  description = "Private IP assigned to the Private Endpoint"
  value       = azurerm_private_endpoint.pe.private_service_connection[0].private_ip_address
}
