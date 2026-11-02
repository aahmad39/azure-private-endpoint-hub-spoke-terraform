output "dns_zones" {
  value = azurerm_private_dns_zone.dns_zone
}

output "vnet_links" {
  value = azurerm_private_dns_zone_virtual_network_link.vnet_link
}
