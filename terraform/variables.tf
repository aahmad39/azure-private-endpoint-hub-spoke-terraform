variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "rg-private-endpoint-demo"
}

variable "vm_vnet_address_space" {
  description = "Address space for VM VNet"
  type        = list(string)
  default     = ["10.143.0.0/16"]
}

variable "vm_subnet_address_prefix" {
  description = "Subnet address prefix for VM Subnet"
  type        = list(string)
  default     = ["10.143.0.0/24"]
}

variable "hub_vnet_address_space" {
  description = "Address space for Hub VNet"
  type        = list(string)
  default     = ["10.124.0.0/16"]
}

variable "pe_subnet_address_prefix" {
  description = "Subnet address prefix for Private Endpoint Subnet"
  type        = list(string)
  default     = ["10.124.0.0/24"]
}

variable "admin_username" {
  description = "Username for Linux Virtual Machine"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Password for Linux Virtual Machine"
  type        = string
  sensitive   = true
  default     = "AzureP@ssw0rd1234!"
}

variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_B1s"
}
