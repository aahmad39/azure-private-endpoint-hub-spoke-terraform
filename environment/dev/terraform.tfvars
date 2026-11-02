rg-dev = {
  rg1 = {
    name     = "rg-private-endpoint-dev"
    location = "eastus"
    tags = {
      Environment = "Development"
      Project     = "Private-Endpoint-Automation"
    }
  }
}

vnet-dev = {
  vnet1 = {
    name          = "vnet-vm-spoke"
    location      = "eastus"
    rg_name       = "rg-private-endpoint-dev"
    address_space = ["10.143.0.0/16"]
  }
  vnet2 = {
    name          = "vnet-hub"
    location      = "eastus"
    rg_name       = "rg-private-endpoint-dev"
    address_space = ["10.124.0.0/16"]
  }
}

subnet-dev = {
  subnet1 = {
    name        = "snet-vm"
    rg_name     = "rg-private-endpoint-dev"
    vnet_name   = "vnet-vm-spoke"
    address_pre = ["10.143.0.0/24"]
  }
  subnet2 = {
    name        = "snet-pe"
    rg_name     = "rg-private-endpoint-dev"
    vnet_name   = "vnet-hub"
    address_pre = ["10.124.0.0/24"]
  }
}

peering-dev = {
  peering1 = {
    name             = "peer-spoke-to-hub"
    rg_name          = "rg-private-endpoint-dev"
    vnet_name        = "vnet-vm-spoke"
    remote_vnet_name = "vnet-hub"
    remote_rg_name   = "rg-private-endpoint-dev"
  }
  peering2 = {
    name             = "peer-hub-to-spoke"
    rg_name          = "rg-private-endpoint-dev"
    vnet_name        = "vnet-hub"
    remote_vnet_name = "vnet-vm-spoke"
    remote_rg_name   = "rg-private-endpoint-dev"
  }
}

pip-dev = {
  pip1 = {
    name     = "pip-vm-client"
    location = "eastus"
    rg_name  = "rg-private-endpoint-dev"
  }
}

nsg-dev = {
  nsg1 = {
    name     = "nsg-vm-client"
    location = "eastus"
    rg_name  = "rg-private-endpoint-dev"
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

vm-dev = {
  vm1 = {
    name           = "vm-client"
    rg_name        = "rg-private-endpoint-dev"
    location       = "eastus"
    nic_name       = "nic-vm-client"
    vnet_name      = "vnet-vm-spoke"
    subnet_name    = "snet-vm"
    pip_name       = "pip-vm-client"
    nsg_name       = "nsg-vm-client"
    vm_size        = "Standard_B1s"
    admin_username = "azureuser"
    admin_password = "ComplexAzureP@ssw0rd2026!"
  }
}

storage_account-dev = {
  sa1 = {
    storage_account_name     = "dstoragepe2026"
    rg_name                  = "rg-private-endpoint-dev"
    location                 = "eastus"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}

containers-dev = {
  container1 = {
    name                = "data"
    storage_account_key = "sa1"
  }
}

dns_zones-dev = {
  dns1 = {
    name    = "privatelink.blob.core.windows.net"
    rg_name = "rg-private-endpoint-dev"
  }
}

dns_links-dev = {
  link1 = {
    name          = "link-vnet-hub"
    rg_name       = "rg-private-endpoint-dev"
    dns_zone_name = "privatelink.blob.core.windows.net"
    vnet_name     = "vnet-hub"
  }
  link2 = {
    name          = "link-vnet-spoke"
    rg_name       = "rg-private-endpoint-dev"
    dns_zone_name = "privatelink.blob.core.windows.net"
    vnet_name     = "vnet-vm-spoke"
  }
}

private_endpoints-dev = {
  pe1 = {
    name                 = "pe-storage-blob"
    location             = "eastus"
    rg_name              = "rg-private-endpoint-dev"
    vnet_name            = "vnet-hub"
    subnet_name          = "snet-pe"
    connection_name      = "psc-blob"
    storage_account_name = "dstoragepe2026"
    dns_zone_name        = "privatelink.blob.core.windows.net"
  }
}
