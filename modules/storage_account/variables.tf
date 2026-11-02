variable "storage_accounts" {
  description = "Map of Storage Accounts"
  type = map(object({
    name_prefix                   = string
    resource_group_name           = string
    location                      = string
    account_tier                  = optional(string, "Standard")
    account_replication_type      = optional(string, "LRS")
    public_network_access_enabled = optional(bool, false)
    tags                          = optional(map(string), {})
  }))
}

variable "containers" {
  description = "Map of Blob Containers"
  type = map(object({
    name                  = string
    storage_account_key   = string
    container_access_type = optional(string, "private")
  }))
  default = {}
}
