variable "private_endpoints" {
  description = "Map of Private Endpoints"
  type = map(object({
    name                 = string
    location             = string
    resource_group_name  = string
    subnet_id            = string
    connection_name      = string
    target_resource_id   = string
    subresource_names    = list(string)
    is_manual_connection = optional(bool, false)
    dns_zone_ids         = optional(list(string), [])
    tags                 = optional(map(string), {})
  }))
}
