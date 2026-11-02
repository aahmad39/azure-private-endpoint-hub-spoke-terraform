# Azure Storage Private Endpoint with Hub-Spoke VNet Peering & Private DNS

This repository uses a clean **Environment-Module (Parent-Child) Pattern** using clean **nested maps** for VNets and Subnets, avoiding unnecessary code complexity.

---

## 🏗️ Repository Structure

```text
d:\private_endpoint_github/
├── .gitignore
├── README.md
├── modules/                                      # 🧩 CHILD MODULE (All resources encapsulated here)
│   └── private_endpoint_architecture/
│       ├── main.tf                               # RG, VNets, Subnets, Peering, VM, Storage, PE, Private DNS
│       ├── variables.tf                          # Variable schemas with nested map
│       └── outputs.tf                            # Output values
│
└── environments/                                 # 🏢 PARENT ENVIRONMENT MODULES
    └── dev/                                      # Development Environment
        ├── provider.tf
        ├── main.tf                               # Root Parent calling the child module
        ├── variables.tf
        ├── terraform.tfvars                      # Nested Map configurations
        ├── terraform.tfvars.example
        └── outputs.tf
```

---

## 🗺️ Nested Map Configuration

All network and subnet configurations are managed cleanly via **nested maps** in [`environments/dev/terraform.tfvars`](file:///d:/private_endpoint_github/environments/dev/terraform.tfvars):

```hcl
# Nested Map for VNets and Subnets (as per diagram: 10.143.0.0/16 and 10.124.0.0/16)
vnets = {
  "vnet-spoke-vm" = {
    address_space = ["10.143.0.0/16"]
    subnets = {
      "snet-vm" = {
        address_prefix = "10.143.0.0/24"
      }
    }
  }

  "vnet-hub" = {
    address_space = ["10.124.0.0/16"]
    subnets = {
      "snet-pe" = {
        address_prefix = "10.124.0.0/24"
      }
    }
  }
}
```

---

## 📐 Architecture & Flow

```
+-------------------------------------------------------+       +-------------------------------------------------------+
|  VM Spoke VNet (10.143.0.0/16)                        |       |  Hub VNet (10.124.0.0/16)                             |
|                                                       |       |                                                       |
|  +-------------------------------------------------+  |       |  +-------------------------------------------------+  |
|  | VM Subnet (10.143.0.0/24)                       |  |       |  | PE Subnet (10.124.0.0/24)                       |  |
|  |                                                 |  |       |  |                                                 |  |
|  |  +-------------------+                          |  |       |  |  +-------------------+                          |  |
|  |  |  Client VM        |                          |  |       |  |  | Private Endpoint  |---(Private Service Link)-+  |
|  |  |  10.143.0.4       |                          |  |       |  |  | 10.124.0.4        |                          |  |
|  |  +-------------------+                          |  |       |  |  +-------------------+                          |  |
|  +-------------------------------------------------+  |       |  +-------------------------------------------------+  |
+-------------------------------------------------------+       +-------------------------------------------------------+
                           ^                                                               ^
                           |                                                               |
                           +================== Bi-directional Peering =====================+
                                                                                           |
                                                                                           v
                                                         +-------------------------------------------------------------+
                                                         | Azure Storage Account (Public Access Disabled)              |
                                                         | - Container: data                                           |
                                                         +-------------------------------------------------------------+
                                                                                           ^
                                                                                           |
                                                         +-------------------------------------------------------------+
                                                         | Azure Private DNS Zone: privatelink.blob.core.windows.net   |
                                                         | - Linked to: VM Spoke VNet & Hub VNet                       |
                                                         +-------------------------------------------------------------+
```

---

## 🚀 How to Deploy

1. **Go to the Environment Directory:**
   ```bash
   cd environments/dev
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Validate & Plan:**
   ```bash
   terraform validate
   terraform plan
   ```

4. **Deploy:**
   ```bash
   terraform apply -auto-approve
   ```

---

## 🧪 Testing & Verification

1. **SSH into the VM:**
   ```bash
   ssh azureuser@<vm_public_ip>
   ```

2. **DNS Resolution Check:**
   ```bash
   nslookup <storage_account_name>.blob.core.windows.net
   ```
   *The FQDN will resolve directly to `<storage_account_name>.privatelink.blob.core.windows.net` and point to the Private Endpoint IP (`10.124.0.4`).*
