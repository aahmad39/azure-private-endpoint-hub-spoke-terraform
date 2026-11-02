resource "random_string" "suffix" {
  for_each = var.storage_accounts
  length   = 6
  special  = false
  upper    = false
}

resource "azurerm_storage_account" "str" {
  for_each                      = var.storage_accounts
  name                          = "${each.value.storage_account_name}${random_string.suffix[each.key].result}"
  resource_group_name           = each.value.rg_name
  location                      = each.value.location
  account_tier                  = try(each.value.account_tier, "Standard")
  account_replication_type      = try(each.value.account_replication_type, "LRS")
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = try(each.value.public_network_access_enabled, false)
}

resource "azurerm_storage_container" "container" {
  for_each              = var.containers
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.str[each.value.storage_account_key].name
  container_access_type = try(each.value.container_access_type, "private")
}
