variable "resource_group" {
  description = "Resource group configurations"
  type = object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  })
}

variable "vnets" {
  description = "Nested map of VNets and their corresponding subnets"
  type = map(object({
    address_space = list(string)
    subnets = map(object({
      address_prefix = string
    }))
  }))
}

variable "peering" {
  description = "VNets to peer with each other"
  type = object({
    vnet_a_key = string
    vnet_b_key = string
  })
}

variable "vm_config" {
  description = "Virtual Machine configuration"
  type = object({
    name           = string
    size           = string
    subnet_key     = string
    admin_username = string
    admin_password = string
  })
}

variable "storage_config" {
  description = "Storage and Private Endpoint configuration"
  type = object({
    prefix         = string
    container_name = string
    pe_name        = string
    pe_subnet_key  = string
  })
}
