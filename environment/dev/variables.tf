variable "rg-dev" {
  description = "Resource Groups configuration map for dev environment"
  default     = {}
}

variable "vnet-dev" {
  description = "Virtual Networks configuration map for dev environment"
  default     = {}
}

variable "subnet-dev" {
  description = "Subnets configuration map for dev environment"
  default     = {}
}

variable "peering-dev" {
  description = "VNet Peering configuration map for dev environment"
  default     = {}
}

variable "pip-dev" {
  description = "Public IPs configuration map for dev environment"
  default     = {}
}

variable "nsg-dev" {
  description = "Network Security Groups configuration map for dev environment"
  default     = {}
}

variable "vm-dev" {
  description = "Virtual Machines and NIC configuration map for dev environment"
  default     = {}
}

variable "storage_account-dev" {
  description = "Storage Accounts configuration map for dev environment"
  default     = {}
}

variable "containers-dev" {
  description = "Blob Containers configuration map for dev environment"
  default     = {}
}

variable "dns_zones-dev" {
  description = "Private DNS Zones configuration map for dev environment"
  default     = {}
}

variable "dns_links-dev" {
  description = "DNS Zone links configuration map for dev environment"
  default     = {}
}

variable "private_endpoints-dev" {
  description = "Private Endpoints configuration map for dev environment"
  default     = {}
}
