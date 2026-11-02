# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group.name
  location = var.resource_group.location
  tags     = var.resource_group.tags
}

# 2. Virtual Networks & Subnets (using nested map)
resource "azurerm_virtual_network" "vnets" {
  for_each            = var.vnets
  name                = each.key
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = each.value.address_space
}

locals {
  # Flatten nested subnets: key = "vnet_name-subnet_name"
  subnets = merge([
    for vnet_key, vnet_val in var.vnets : {
      for subnet_key, subnet_val in vnet_val.subnets :
      "${vnet_key}-${subnet_key}" => {
        vnet_name      = vnet_key
        subnet_name    = subnet_key
        address_prefix = subnet_val.address_prefix
      }
    }
  ]...)
}

resource "azurerm_subnet" "subnets" {
  for_each             = local.subnets
  name                 = each.value.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnets[each.value.vnet_name].name
  address_prefixes     = [each.value.address_prefix]
}

# 4. VNet Peering (Two-Way)
resource "azurerm_virtual_network_peering" "peering_vm_to_hub" {
  name                         = "peer-vm-to-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnets[var.peering.vnet_a_key].name
  remote_virtual_network_id    = azurerm_virtual_network.vnets[var.peering.vnet_b_key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "peering_hub_to_vm" {
  name                         = "peer-hub-to-vm"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnets[var.peering.vnet_b_key].name
  remote_virtual_network_id    = azurerm_virtual_network.vnets[var.peering.vnet_a_key].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# 3. Client Virtual Machine
resource "azurerm_public_ip" "pip" {
  name                = "${var.vm_config.name}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.vm_config.name}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vm_config.name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets[var.vm_config.subnet_key].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vm_config.name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = var.vm_config.size
  admin_username                  = var.vm_config.admin_username
  admin_password                  = var.vm_config.admin_password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

# 7. Private DNS Zone & VNet Links
resource "azurerm_private_dns_zone" "blob_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_links" {
  for_each              = azurerm_virtual_network.vnets
  name                  = "link-${each.key}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.blob_dns.name
  virtual_network_id    = each.value.id
}

# 5 & 6. Storage Account & Private Endpoint
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "sa" {
  name                     = "${var.storage_config.prefix}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Public network access blocked
  public_network_access_enabled = false
}

resource "azurerm_storage_container" "container" {
  name                  = var.storage_config.container_name
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_private_endpoint" "pe" {
  name                = var.storage_config.pe_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnets[var.storage_config.pe_subnet_key].id

  private_service_connection {
    name                           = "psc-blob"
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "blob-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.blob_dns.id]
  }
}
