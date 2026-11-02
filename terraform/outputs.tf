output "resource_group_name" {
  value = module.resource_group.name
}

output "storage_account_name" {
  value = module.storage_pe.storage_account_name
}

output "storage_account_blob_endpoint" {
  value = module.storage_pe.primary_blob_endpoint
}

output "private_endpoint_ip" {
  description = "Private IP of the Storage Account Private Endpoint in Hub VNet"
  value       = module.storage_pe.private_endpoint_ip
}

output "vm_public_ip" {
  description = "Public IP of the testing VM"
  value       = module.client_vm.public_ip
}

output "vm_private_ip" {
  description = "Private IP of the VM inside Spoke VNet"
  value       = module.client_vm.private_ip
}

output "ssh_command" {
  description = "SSH Command to connect to the test VM"
  value       = "ssh ${var.admin_username}@${module.client_vm.public_ip}"
}
