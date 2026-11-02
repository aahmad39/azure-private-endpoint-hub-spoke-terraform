variable "linux_vms" {
  description = "Map of Linux Virtual Machines"
  type = map(object({
    name                  = string
    resource_group_name   = string
    location              = string
    size                  = optional(string, "Standard_B1s")
    admin_username        = string
    admin_password        = string
    network_interface_ids = list(string)
    os_disk_type          = optional(string, "Standard_LRS")
    image_publisher       = optional(string, "Canonical")
    image_offer           = optional(string, "0001-com-ubuntu-server-jammy")
    image_sku             = optional(string, "22_04-lts-gen2")
    image_version         = optional(string, "latest")
    tags                  = optional(map(string), {})
  }))
}
