output "virtual_machines" {
  value = azurerm_linux_virtual_machine.main
}

output "network_interfaces" {
  value = azurerm_network_interface.nic
}
