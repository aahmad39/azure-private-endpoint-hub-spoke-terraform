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
  peering    = var.peering-dev
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
  vms        = var.vm-dev
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
  dns_links  = var.dns_links-dev
}

module "private_endpoint-dev" {
  depends_on        = [module.subnet-dev, module.storage_account-dev, module.private_dns-dev]
  source            = "../../modules/private_endpoint"
  private_endpoints = var.private_endpoints-dev
}
