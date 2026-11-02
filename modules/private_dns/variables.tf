variable "dns_zones" {
  description = "Map of Private DNS Zones"
  type = map(object({
    name                = string
    resource_group_name = string
    tags                = optional(map(string), {})
  }))
}

variable "vnet_links" {
  description = "Map of DNS Zone to VNet Links"
  type = map(object({
    name                = string
    resource_group_name = string
    dns_zone_key        = string
    virtual_network_id  = string
  }))
  default = {}
}
