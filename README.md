# Azure Storage Private Endpoint with Hub-Spoke VNet Peering & Private DNS

This repository contains production-ready **Terraform** configuration to implement secure, private connectivity to an **Azure Storage Account (Blob Storage)** from a Virtual Machine located in a peered Virtual Network using **Azure Private Endpoint** and **Azure Private DNS Zone**.

---

## 📐 Architecture Diagram

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

## 🛠️ Step-by-Step Implementation Flow

1. **Resource Group**: A centralized resource group for all network and storage resources.
2. **Virtual Networks**:
   - `vnet-vm-spoke` with address space `10.143.0.0/16`
   - `vnet-hub` with address space `10.124.0.0/16`
3. **Subnets & VM**:
   - `snet-vm` (`10.143.0.0/24`) hosting an Ubuntu Linux VM (`vm-client`).
   - `snet-pe` (`10.124.0.0/24`) designated for the Storage Private Endpoint.
4. **VNet Peering**: Full two-way peering established between Spoke and Hub VNets.
5. **Storage Account & Private Endpoint**:
   - Azure Storage Account with `public_network_access_enabled = false`.
   - Private Endpoint created inside `snet-pe` receiving a private IP (`10.124.0.x`).
6. **Private DNS Zone (`privatelink.blob.core.windows.net`)**:
   - Automatically registers Private Endpoint IP via `private_dns_zone_group`.
   - Linked to both **Hub VNet** and **VM Spoke VNet** so names resolve directly from the VM.
7. **Validation & Testing**:
   - Connecting via SSH to the VM.
   - Performing DNS verification with `nslookup`.
   - Accessing blob storage securely through the private IP channel.

---

## 🚀 Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.3.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) logged in (`az login`)

### Deployment Steps

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd <your-repo-folder>/terraform
   ```

2. **Configure Variables:**
   Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   Edit `terraform.tfvars` to customize credentials or region as needed.

3. **Initialize and Deploy Terraform:**
   ```bash
   terraform init
   terraform plan
   terraform apply -auto-approve
   ```

4. **Outputs:**
   Once completed, Terraform outputs:
   - `storage_account_name`
   - `private_endpoint_ip`
   - `vm_public_ip`
   - `ssh_command`

---

## 🧪 Verification & DNS Testing

1. **SSH into the VM:**
   ```bash
   ssh <admin_username>@<vm_public_ip>
   ```

2. **Test DNS Resolution (`nslookup`):**
   ```bash
   nslookup <storage_account_name>.blob.core.windows.net
   ```
   **Expected Output:**
   Notice that the canonical name points to `<storage_account_name>.privatelink.blob.core.windows.net` and resolves to the **Private IP** (`10.124.0.4`):
   ```text
   Server:         127.0.0.53
   Address:        127.0.0.53#53

   Non-authoritative answer:
   <storage_account_name>.blob.core.windows.net canonical name = <storage_account_name>.privatelink.blob.core.windows.net.
   Name:   <storage_account_name>.privatelink.blob.core.windows.net
   Address: 10.124.0.4
   ```

3. **Test Connectivity (Public vs Private):**
   - From your local machine (outside VNet):
     ```bash
     curl -I https://<storage_account_name>.blob.core.windows.net
     ```
     *Result: Access Denied / 403 Forbidden (Public access is completely disabled).*

   - From inside the Linux VM:
     ```bash
     curl -I https://<storage_account_name>.blob.core.windows.net
     ```
     *Result: Resolves and routes completely through Azure Private Endpoint!*

---

## 🧹 Cleanup

To avoid ongoing Azure charges:
```bash
terraform destroy -auto-approve
```
