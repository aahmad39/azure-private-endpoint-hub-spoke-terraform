resource "azurerm_private_endpoint" "pe" {
  for_each            = var.private_endpoints
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  subnet_id           = each.value.subnet_id
  tags                = try(each.value.tags, {})

  private_service_connection {
    name                           = each.value.connection_name
    private_connection_resource_id = each.value.target_resource_id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = try(each.value.is_manual_connection, false)
  }

  dynamic "private_dns_zone_group" {
    for_each = try(each.value.dns_zone_ids, []) != [] ? [1] : []
    content {
      name                 = "default-dns-zone-group"
      private_dns_zone_ids = each.value.dns_zone_ids
    }
  }
}
