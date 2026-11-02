# 1. Parent invokes Resource Group Child Module
module "resource_group" {
  source   = "./modules/resource_group"
  name     = var.resource_group_name
  location = var.location
  tags = {
    Environment  = "Demo"
    Architecture = "Hub-Spoke-Private-Endpoint"
  }
}

# 2. Parent invokes Network Child Module for VM Spoke VNet (10.143.0.0/16)
module "spoke_network" {
  source                  = "./modules/network"
  resource_group_name     = module.resource_group.name
  location                = module.resource_group.location
  vnet_name               = "vnet-vm-spoke"
  address_space           = var.vm_vnet_address_space
  subnet_name             = "snet-vm"
  subnet_address_prefixes = var.vm_subnet_address_prefix
}

# 2. Parent invokes Network Child Module for Hub VNet (10.124.0.0/16)
module "hub_network" {
  source                  = "./modules/network"
  resource_group_name     = module.resource_group.name
  location                = module.resource_group.location
  vnet_name               = "vnet-hub"
  address_space           = var.hub_vnet_address_space
  subnet_name             = "snet-pe"
  subnet_address_prefixes = var.pe_subnet_address_prefix
}

# 4. Parent invokes Peering Child Module (Bi-directional Peering)
module "vnet_peering" {
  source                    = "./modules/peering"
  peering1_name             = "peer-spoke-to-hub"
  peering2_name             = "peer-hub-to-spoke"
  vnet1_resource_group_name = module.resource_group.name
  vnet1_name                = module.spoke_network.vnet_name
  vnet1_id                  = module.spoke_network.vnet_id
  vnet2_resource_group_name = module.resource_group.name
  vnet2_name                = module.hub_network.vnet_name
  vnet2_id                  = module.hub_network.vnet_id
}

# 3. Parent invokes VM Child Module in Spoke VNet
module "client_vm" {
  source              = "./modules/vm"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vm_name             = "vm-client"
  subnet_id           = module.spoke_network.subnet_id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
}

# 7. Parent invokes Private DNS Zone Child Module & links both VNets
module "private_dns" {
  source              = "./modules/private_dns"
  resource_group_name = module.resource_group.name
  zone_name           = "privatelink.blob.core.windows.net"
  vnet_links = {
    "link-hub-vnet"   = module.hub_network.vnet_id
    "link-spoke-vnet" = module.spoke_network.vnet_id
  }
}

# 5 & 6. Parent invokes Storage & Private Endpoint Child Module in Hub VNet
module "storage_pe" {
  source                = "./modules/storage_private_endpoint"
  resource_group_name   = module.resource_group.name
  location              = module.resource_group.location
  storage_prefix        = "dstorage"
  container_name        = "data"
  pe_subnet_id          = module.hub_network.subnet_id
  private_endpoint_name = "pe-storage-blob"
  private_dns_zone_id   = module.private_dns.dns_zone_id
}
