output "resource_group_name" {
  value = module.private_endpoint_infrastructure.resource_group_name
}

output "storage_account_name" {
  value = module.private_endpoint_infrastructure.storage_account_name
}

output "storage_account_blob_endpoint" {
  value = module.private_endpoint_infrastructure.storage_account_blob_endpoint
}

output "private_endpoint_ip" {
  description = "Private IP of Storage Private Endpoint"
  value       = module.private_endpoint_infrastructure.private_endpoint_ip
}

output "vm_public_ip" {
  description = "Public IP of client VM"
  value       = module.private_endpoint_infrastructure.vm_public_ip
}

output "vm_private_ip" {
  description = "Private IP of client VM"
  value       = module.private_endpoint_infrastructure.vm_private_ip
}

output "ssh_command" {
  description = "SSH Command to test connection"
  value       = module.private_endpoint_infrastructure.ssh_command
}
