resource "random_string" "suffix" {
  for_each = var.storage_accounts
  length   = 6
  special  = false
  upper    = false
}

resource "azurerm_storage_account" "sa" {
  for_each                      = var.storage_accounts
  name                          = "${each.value.name_prefix}${random_string.suffix[each.key].result}"
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  account_tier                  = try(each.value.account_tier, "Standard")
  account_replication_type      = try(each.value.account_replication_type, "LRS")
  public_network_access_enabled = try(each.value.public_network_access_enabled, false)
  tags                          = try(each.value.tags, {})
}

resource "azurerm_storage_container" "container" {
  for_each              = var.containers
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.sa[each.value.storage_account_key].name
  container_access_type = try(each.value.container_access_type, "private")
}
