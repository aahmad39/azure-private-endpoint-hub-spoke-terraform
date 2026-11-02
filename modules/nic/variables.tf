variable "network_interfaces" {
  description = "Map of Network Interfaces"
  type = map(object({
    name                          = string
    location                      = string
    resource_group_name           = string
    subnet_id                     = string
    public_ip_address_id          = optional(string, null)
    nsg_id                        = optional(string, null)
    private_ip_address_allocation = optional(string, "Dynamic")
    tags                          = optional(map(string), {})
  }))
}
