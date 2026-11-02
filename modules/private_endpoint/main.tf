data "azurerm_subnet" "subnet" {
  for_each             = var.private_endpoints
  name                 = each.value.subnet_name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.rg_name
}

data "azurerm_storage_account" "sa" {
  for_each            = var.private_endpoints
  name                = each.value.storage_account_name
  resource_group_name = each.value.rg_name
}

data "azurerm_private_dns_zone" "dns" {
  for_each            = var.private_endpoints
  name                = each.value.dns_zone_name
  resource_group_name = each.value.rg_name
}

resource "azurerm_private_endpoint" "this" {
  for_each            = var.private_endpoints
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.rg_name
  subnet_id           = data.azurerm_subnet.subnet[each.key].id

  private_service_connection {
    name                           = each.value.connection_name
    private_connection_resource_id = data.azurerm_storage_account.sa[each.key].id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default-dns-zone-group"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.dns[each.key].id]
  }
}
