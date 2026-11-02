module "rg-dev" {
  source = "../../modules/resource_group"
  rg     = var.rg-dev
}

module "vnet-dev" {
  depends_on = [module.rg-dev]
  source     = "../../modules/vnet"
  vnet       = var.vnet-dev
}

module "subnet-dev" {
  depends_on = [module.vnet-dev]
  source     = "../../modules/subnet"
  subnet     = var.subnet-dev
}

module "peering-dev" {
  depends_on = [module.vnet-dev]
  source     = "../../modules/peering"
  peering = {
    for k, v in var.peering-dev : k => {
      name                         = v.name
      rg_name                      = v.rg_name
      vnet_name                    = v.vnet_name
      remote_vnet_id               = module.vnet-dev.vnets[v.remote_vnet_key].id
      allow_virtual_network_access = try(v.allow_virtual_network_access, true)
      allow_forwarded_traffic      = try(v.allow_forwarded_traffic, true)
    }
  }
}

module "pip-dev" {
  depends_on = [module.rg-dev]
  source     = "../../modules/pip"
  public_ip  = var.pip-dev
}

module "nsg-dev" {
  depends_on = [module.rg-dev]
  source     = "../../modules/nsg"
  nsgs       = var.nsg-dev
}

module "vm-dev" {
  depends_on = [module.subnet-dev, module.pip-dev, module.nsg-dev]
  source     = "../../modules/virtual_machine"
  vms = {
    for k, v in var.vm-dev : k => {
      name           = v.name
      rg_name        = v.rg_name
      location       = v.location
      nic_name       = v.nic_name
      subnet_id      = module.subnet-dev.subnets[v.subnet_key].id
      pip_id         = try(v.pip_key, null) != null ? module.pip-dev.public_ips[v.pip_key].id : null
      nsg_id         = try(v.nsg_key, null) != null ? module.nsg-dev.nsgs[v.nsg_key].id : null
      vm_size        = try(v.vm_size, "Standard_B1s")
      admin_username = v.admin_username
      admin_password = v.admin_password
    }
  }
}

module "storage_account-dev" {
  depends_on       = [module.rg-dev]
  source           = "../../modules/storage_account"
  storage_accounts = var.storage_account-dev
  containers       = var.containers-dev
}

module "private_dns-dev" {
  depends_on = [module.rg-dev, module.vnet-dev]
  source     = "../../modules/private_dns"
  dns_zones  = var.dns_zones-dev
  dns_links = {
    for k, v in var.dns_links-dev : k => {
      name         = v.name
      rg_name      = v.rg_name
      dns_zone_key = v.dns_zone_key
      vnet_id      = module.vnet-dev.vnets[v.vnet_key].id
    }
  }
}

module "private_endpoint-dev" {
  depends_on = [module.subnet-dev, module.storage_account-dev, module.private_dns-dev]
  source     = "../../modules/private_endpoint"
  private_endpoints = {
    for k, v in var.private_endpoints-dev : k => {
      name               = v.name
      location           = v.location
      rg_name            = v.rg_name
      subnet_id          = module.subnet-dev.subnets[v.subnet_key].id
      connection_name    = v.connection_name
      target_resource_id = module.storage_account-dev.storage_accounts[v.storage_account_key].id
      subresource_names  = v.subresource_names
      dns_zone_ids       = [module.private_dns-dev.dns_zones[v.dns_zone_key].id]
    }
  }
}
