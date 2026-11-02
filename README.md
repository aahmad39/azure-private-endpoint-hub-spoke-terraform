# Azure Storage Private Endpoint with Hub-Spoke VNet Peering & Private DNS

This repository provides an enterprise-ready, **Parent-Child Modular Terraform architecture** implementing secure, private connectivity to an **Azure Storage Account (Blob Storage)** from a Virtual Machine located in a peered Virtual Network using **Azure Private Endpoint** and **Azure Private DNS Zone**.

---

## 🏗️ Architecture Design (Parent & Child Modules)

```
d:\private_endpoint_github/
├── .gitignore
├── README.md
└── terraform/
    ├── provider.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars.example
    ├── main.tf                               # <-- Root (Parent) Module calling Child Modules
    └── modules/                              # <-- Reusable Child Modules
        ├── resource_group/                   # 1. Resource Group Module
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        ├── network/                          # 2. Virtual Network & Subnet Module (Used for Spoke & Hub)
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        ├── peering/                          # 4. Bi-directional VNet Peering Module
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        ├── vm/                               # 3. Linux Virtual Machine, NIC, NSG & PIP Module
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        ├── private_dns/                      # 7. Private DNS Zone & Multi-VNet Links Module
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        └── storage_private_endpoint/         # 5 & 6. Storage Account & Private Endpoint Module
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
```

---

## 📐 Network & Resource Flow Diagram

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

## 🛠️ Step-by-Step Implementation

1. **Resource Group**: Created via `modules/resource_group`.
2. **2 VNets & Subnets**:
   - `modules/network` creates Spoke VNet (`10.143.0.0/16`) with `snet-vm` (`10.143.0.0/24`).
   - `modules/network` creates Hub VNet (`10.124.0.0/16`) with `snet-pe` (`10.124.0.0/24`).
3. **VM**: Created via `modules/vm` in `snet-vm`.
4. **VNet Peering**: Two-way peering configured via `modules/peering`.
5. **Private Endpoint & Storage Account**:
   - Configured via `modules/storage_private_endpoint` with public access disabled.
   - Private Endpoint is connected to `snet-pe` and acquires a private IP (`10.124.0.x`).
6. **Private DNS Zone (`privatelink.blob.core.windows.net`)**:
   - Created via `modules/private_dns`.
   - Linked to both Hub and Spoke VNets so DNS queries from the VM automatically resolve to the private endpoint IP.
7. **Testing & Validation**:
   - SSH to VM.
   - Run `nslookup <storage_account>.blob.core.windows.net` to verify resolution to the private IP.

---

## 🚀 Deployment Instructions

### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) >= 1.3.0
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) logged in (`az login`)

### Commands
```bash
cd terraform

# 1. Initialize modules and providers
terraform init

# 2. Validate configuration
terraform validate

# 3. Plan deployment
terraform plan

# 4. Apply deployment
terraform apply -auto-approve
```

---

## 🧪 DNS Verification Steps

1. **SSH into the VM:**
   ```bash
   ssh <admin_username>@<vm_public_ip>
   ```

2. **Verify DNS Resolution:**
   ```bash
   nslookup <storage_account_name>.blob.core.windows.net
   ```
   **Output Verification:**
   The output must resolve to `<storage_account_name>.privatelink.blob.core.windows.net` with the Private IP:
   ```text
   Non-authoritative answer:
   <storage_account_name>.blob.core.windows.net canonical name = <storage_account_name>.privatelink.blob.core.windows.net.
   Name:   <storage_account_name>.privatelink.blob.core.windows.net
   Address: 10.124.0.4
   ```

---

## 🧹 Cleanup
```bash
terraform destroy -auto-approve
```
