variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_prefix" {
  type    = string
  default = "dstorage"
}

variable "container_name" {
  type    = string
  default = "data"
}

variable "pe_subnet_id" {
  type = string
}

variable "private_endpoint_name" {
  type    = string
  default = "pe-storage-blob"
}

variable "private_dns_zone_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
