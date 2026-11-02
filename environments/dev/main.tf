# Environment Dev (Parent/Root) calls the child module
module "private_endpoint_infrastructure" {
  source = "../../modules/private_endpoint_architecture"

  resource_group = var.resource_group
  vnets          = var.vnets
  peering        = var.peering
  vm_config      = var.vm_config
  storage_config = var.storage_config
}
