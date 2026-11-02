variable "resource_group_name" {
  type = string
}

variable "zone_name" {
  type    = string
  default = "privatelink.blob.core.windows.net"
}

variable "vnet_links" {
  description = "Map of VNet link names to VNet resource IDs"
  type        = map(string)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
