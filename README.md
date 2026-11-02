# Azure Private Endpoint Automation (Granular Reusable Modules Architecture)

This repository implements the end-to-end automation for connecting an Azure Virtual Machine to an Azure Storage Account through an **Azure Private Endpoint**, **Hub-Spoke VNet Peering**, and **Azure Private DNS Zone**.

Every individual Azure resource is decoupled into its own independent, reusable **Child Module**, while the environment root (`environments/dev`) serves as the **Parent Module** that connects the modules using clean **nested maps**.

---

## 🏗️ Architecture & Module Organization

```text
d:\private_endpoint_github/
├── .gitignore
├── README.md
│
├── modules/                                   # 🧩 INDEPENDENT REUSABLE CHILD MODULES
│   ├── resource_group/                        # Azure Resource Groups
│   ├── vnet/                                  # Virtual Networks
│   ├── subnet/                                # Subnets
│   ├── peering/                               # VNet Peerings (Bi-directional)
│   ├── public_ip/                             # Public IP Addresses
│   ├── nsg/                                   # Network Security Groups & Rules
│   ├── nic/                                   # Network Interfaces & NSG Association
│   ├── virtual_machine/                       # Linux Virtual Machines
│   ├── storage_account/                       # Storage Accounts & Blob Containers
│   ├── private_dns/                           # Private DNS Zones & Virtual Network Links
│   └── private_endpoint/                      # Private Endpoints & PSC Links
│
└── environments/                              # 🏢 PARENT ENVIRONMENT ROOT
    └── dev/                                   # Development Environment
        ├── provider.tf                        # azurerm & random providers
        ├── main.tf                            # Parent orchestrator calling each child module
        ├── variables.tf                       # Declarations
        ├── terraform.tfvars                   # Variable inputs (Nested Maps)
        ├── terraform.tfvars.example
        └── outputs.tf                         # Output values
```

---

## 🗺️ Nested Maps in Action (`terraform.tfvars`)

Har ek resource ek clear key-value structure se defined hai:
- **VNets & Subnets**: Spoke (`10.143.0.0/16` & `/24`) aur Hub (`10.124.0.0/16` & `/24`).
- **Peering**: Spoke-to-Hub aur Hub-to-Spoke referencing `hub_vnet` & `spoke_vnet`.
- **Private DNS & Links**: `privatelink.blob.core.windows.net` linked with both VNets.
- **Private Endpoint**: Storage Account aur Subnet ko connect karta hai with automatic DNS registration.

---

## 🚀 How to Deploy

1. **Navigate to the dev environment:**
   ```bash
   cd environments/dev
   ```

2. **Initialize all 11 child modules:**
   ```bash
   terraform init
   ```

3. **Verify and Plan:**
   ```bash
   terraform validate
   terraform plan
   ```

4. **Deploy:**
   ```bash
   terraform apply -auto-approve
   ```

---

## 🧪 Verification & DNS Testing

1. **SSH to Linux VM:**
   ```bash
   ssh azureuser@<vm_public_ip>
   ```

2. **Run nslookup on Storage Account FQDN:**
   ```bash
   nslookup <storage_account_name>.blob.core.windows.net
   ```
   **Output:**
   ```text
   <storage_account_name>.blob.core.windows.net canonical name = <storage_account_name>.privatelink.blob.core.windows.net.
   Name:   <storage_account_name>.privatelink.blob.core.windows.net
   Address: 10.124.0.4
   ```
