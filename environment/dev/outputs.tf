output "resource_groups" {
  value = module.rg-dev.resource_groups
}

output "storage_accounts" {
  value = module.storage_account-dev.storage_accounts
}

output "private_endpoint_ip" {
  value = values(module.private_endpoint-dev.private_endpoints)[0].private_service_connection[0].private_ip_address
}

output "vm_public_ip" {
  value = values(module.pip-dev.public_ips)[0].ip_address
}

output "vm_private_ip" {
  value = values(module.vm-dev.network_interfaces)[0].private_ip_address
}

output "ssh_command" {
  value = "ssh azureuser@${values(module.pip-dev.public_ips)[0].ip_address}"
}
