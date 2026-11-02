# 1. Resource Group
resource_groups = {
  "rg1" = {
    name     = "rg-private-endpoint-dev"
    location = "eastus"
    tags = {
      Environment = "Development"
      Project     = "Private-Endpoint-Automation"
    }
  }
}

# 2. Virtual Networks (10.143.0.0/16 & 10.124.0.0/16)
vnets = {
  "spoke_vnet" = {
    name                = "vnet-vm-spoke"
    location            = "eastus"
    resource_group_name = "rg-private-endpoint-dev"
    address_space       = ["10.143.0.0/16"]
  }
  "hub_vnet" = {
    name                = "vnet-hub"
    location            = "eastus"
    resource_group_name = "rg-private-endpoint-dev"
    address_space       = ["10.124.0.0/16"]
  }
}

# 3. Subnets (10.143.0.0/24 & 10.124.0.0/24)
subnets = {
  "vm_subnet" = {
    name                 = "snet-vm"
    resource_group_name  = "rg-private-endpoint-dev"
    virtual_network_name = "vnet-vm-spoke"
    address_prefixes     = ["10.143.0.0/24"]
  }
  "pe_subnet" = {
    name                 = "snet-pe"
    resource_group_name  = "rg-private-endpoint-dev"
    virtual_network_name = "vnet-hub"
    address_prefixes     = ["10.124.0.0/24"]
  }
}

# 4. Peering
peerings = {
  "spoke_to_hub" = {
    name                 = "peer-spoke-to-hub"
    resource_group_name  = "rg-private-endpoint-dev"
    virtual_network_name = "vnet-vm-spoke"
    remote_vnet_key      = "hub_vnet"
  }
  "hub_to_spoke" = {
    name                 = "peer-hub-to-spoke"
    resource_group_name  = "rg-private-endpoint-dev"
    virtual_network_name = "vnet-hub"
    remote_vnet_key      = "spoke_vnet"
  }
}

# 5. Public IP
public_ips = {
  "vm_pip" = {
    name                = "pip-vm-client"
    location            = "eastus"
    resource_group_name = "rg-private-endpoint-dev"
    allocation_method   = "Static"
    sku                 = "Standard"
  }
}

# 6. NSG
network_security_groups = {
  "vm_nsg" = {
    name                = "nsg-vm-client"
    location            = "eastus"
    resource_group_name = "rg-private-endpoint-dev"
    security_rules = [
      {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
}

# 7. NIC
network_interfaces = {
  "vm_nic" = {
    name                = "nic-vm-client"
    location            = "eastus"
    resource_group_name = "rg-private-endpoint-dev"
    subnet_key          = "vm_subnet"
    public_ip_key       = "vm_pip"
    nsg_key             = "vm_nsg"
  }
}

# 8. Virtual Machine
linux_vms = {
  "vm_client" = {
    name                = "vm-client"
    resource_group_name = "rg-private-endpoint-dev"
    location            = "eastus"
    size                = "Standard_B1s"
    admin_username      = "azureuser"
    admin_password      = "ComplexAzureP@ssw0rd2026!"
    nic_key             = "vm_nic"
  }
}

# 9. Storage Account & Container
storage_accounts = {
  "sa1" = {
    name_prefix                   = "dstorage"
    resource_group_name           = "rg-private-endpoint-dev"
    location                      = "eastus"
    account_tier                  = "Standard"
    account_replication_type      = "LRS"
    public_network_access_enabled = false
  }
}

containers = {
  "data_container" = {
    name                = "data"
    storage_account_key = "sa1"
  }
}

# 10. Private DNS Zone & VNet Links
dns_zones = {
  "blob_dns" = {
    name                = "privatelink.blob.core.windows.net"
    resource_group_name = "rg-private-endpoint-dev"
  }
}

vnet_links = {
  "hub_link" = {
    name                = "link-vnet-hub"
    resource_group_name = "rg-private-endpoint-dev"
    dns_zone_key        = "blob_dns"
    vnet_key            = "hub_vnet"
  }
  "spoke_link" = {
    name                = "link-vnet-spoke"
    resource_group_name = "rg-private-endpoint-dev"
    dns_zone_key        = "blob_dns"
    vnet_key            = "spoke_vnet"
  }
}

# 11. Private Endpoint
private_endpoints = {
  "blob_pe" = {
    name                = "pe-storage-blob"
    location            = "eastus"
    resource_group_name = "rg-private-endpoint-dev"
    subnet_key          = "pe_subnet"
    connection_name     = "psc-blob"
    storage_account_key = "sa1"
    subresource_names   = ["blob"]
    dns_zone_key        = "blob_dns"
  }
}
