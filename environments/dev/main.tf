# 1. Resource Group Module
module "resource_group" {
  source          = "../../modules/resource_group"
  resource_groups = var.resource_groups
}

# 2. VNet Module
module "vnet" {
  source = "../../modules/vnet"
  vnets  = var.vnets

  depends_on = [module.resource_group]
}

# 3. Subnet Module
module "subnet" {
  source  = "../../modules/subnet"
  subnets = var.subnets

  depends_on = [module.vnet]
}

# 4. Peering Module
module "peering" {
  source = "../../modules/peering"
  peerings = {
    for k, v in var.peerings : k => {
      name                         = v.name
      resource_group_name          = v.resource_group_name
      virtual_network_name         = v.virtual_network_name
      remote_virtual_network_id    = module.vnet.vnets[v.remote_vnet_key].id
      allow_virtual_network_access = try(v.allow_virtual_network_access, true)
      allow_forwarded_traffic      = try(v.allow_forwarded_traffic, true)
    }
  }

  depends_on = [module.vnet]
}

# 5. Public IP Module
module "public_ip" {
  source     = "../../modules/public_ip"
  public_ips = var.public_ips

  depends_on = [module.resource_group]
}

# 6. NSG Module
module "nsg" {
  source                  = "../../modules/nsg"
  network_security_groups = var.network_security_groups

  depends_on = [module.resource_group]
}

# 7. NIC Module
module "nic" {
  source = "../../modules/nic"
  network_interfaces = {
    for k, v in var.network_interfaces : k => {
      name                          = v.name
      location                      = v.location
      resource_group_name           = v.resource_group_name
      subnet_id                     = module.subnet.subnets[v.subnet_key].id
      public_ip_address_id          = v.public_ip_key != null ? module.public_ip.public_ips[v.public_ip_key].id : null
      nsg_id                        = v.nsg_key != null ? module.nsg.network_security_groups[v.nsg_key].id : null
      private_ip_address_allocation = try(v.private_ip_address_allocation, "Dynamic")
      tags                          = try(v.tags, {})
    }
  }

  depends_on = [module.subnet, module.public_ip, module.nsg]
}

# 8. Virtual Machine Module
module "virtual_machine" {
  source = "../../modules/virtual_machine"
  linux_vms = {
    for k, v in var.linux_vms : k => {
      name                  = v.name
      resource_group_name   = v.resource_group_name
      location              = v.location
      size                  = try(v.size, "Standard_B1s")
      admin_username        = v.admin_username
      admin_password        = v.admin_password
      network_interface_ids = [module.nic.network_interfaces[v.nic_key].id]
      tags                  = try(v.tags, {})
    }
  }

  depends_on = [module.nic]
}

# 9. Storage Account Module
module "storage_account" {
  source           = "../../modules/storage_account"
  storage_accounts = var.storage_accounts
  containers       = var.containers

  depends_on = [module.resource_group]
}

# 10. Private DNS Zone Module
module "private_dns" {
  source    = "../../modules/private_dns"
  dns_zones = var.dns_zones
  vnet_links = {
    for k, v in var.vnet_links : k => {
      name                = v.name
      resource_group_name = v.resource_group_name
      dns_zone_key        = v.dns_zone_key
      virtual_network_id  = module.vnet.vnets[v.vnet_key].id
    }
  }

  depends_on = [module.resource_group, module.vnet]
}

# 11. Private Endpoint Module
module "private_endpoint" {
  source = "../../modules/private_endpoint"
  private_endpoints = {
    for k, v in var.private_endpoints : k => {
      name                 = v.name
      location             = v.location
      resource_group_name  = v.resource_group_name
      subnet_id            = module.subnet.subnets[v.subnet_key].id
      connection_name      = v.connection_name
      target_resource_id   = module.storage_account.storage_accounts[v.storage_account_key].id
      subresource_names    = v.subresource_names
      dns_zone_ids         = [module.private_dns.dns_zones[v.dns_zone_key].id]
      is_manual_connection = try(v.is_manual_connection, false)
      tags                 = try(v.tags, {})
    }
  }

  depends_on = [module.subnet, module.storage_account, module.private_dns]
}
