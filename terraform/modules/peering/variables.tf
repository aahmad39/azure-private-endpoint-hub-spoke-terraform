variable "peering1_name" {
  type    = string
  default = "peer-vnet1-to-vnet2"
}

variable "peering2_name" {
  type    = string
  default = "peer-vnet2-to-vnet1"
}

variable "vnet1_resource_group_name" {
  type = string
}

variable "vnet1_name" {
  type = string
}

variable "vnet1_id" {
  type = string
}

variable "vnet2_resource_group_name" {
  type = string
}

variable "vnet2_name" {
  type = string
}

variable "vnet2_id" {
  type = string
}
