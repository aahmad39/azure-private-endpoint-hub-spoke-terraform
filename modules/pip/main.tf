resource "azurerm_public_ip" "this" {
  for_each            = var.public_ip
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.rg_name
  allocation_method   = try(each.value.allocation_method, "Static")
  sku                 = try(each.value.sku, "Standard")
}

