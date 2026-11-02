output "resource_groups" {
  value = module.resource_group.resource_groups
}

output "storage_account_name" {
  value = values(module.storage_account.storage_accounts)[0].name
}

output "storage_account_blob_endpoint" {
  value = values(module.storage_account.storage_accounts)[0].primary_blob_endpoint
}

output "private_endpoint_ip" {
  value = values(module.private_endpoint.private_endpoints)[0].private_service_connection[0].private_ip_address
}

output "vm_public_ip" {
  value = values(module.public_ip.public_ips)[0].ip_address
}

output "vm_private_ip" {
  value = values(module.nic.network_interfaces)[0].private_ip_address
}

output "ssh_command" {
  value = "ssh azureuser@${values(module.public_ip.public_ips)[0].ip_address}"
}
