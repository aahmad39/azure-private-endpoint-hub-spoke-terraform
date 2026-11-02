# Azure Private Endpoint Automation (Reference DevOps Project Structure)

This repository follows the exact clean, modular pattern established in `D:\Terraform-BestPractices-ado pipeline_ver.01\adnan_devops_project`.

---

## 🏗️ Folder Structure

```text
d:\private_endpoint_github/
├── .gitignore
├── README.md
│
├── modules/                                  # Reusable Child Modules
│   ├── resource_group/                       # RG Module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── vnet/                                 # VNet Module
│   ├── subnet/                               # Subnet Module
│   ├── peering/                              # Peering Module
│   ├── pip/                                  # Public IP Module
│   ├── nsg/                                  # NSG Module
│   ├── virtual_machine/                      # VM & NIC Module
│   ├── storage_account/                      # Storage Account & Container Module
│   ├── private_dns/                          # Private DNS Zone & VNet Link Module
│   └── private_endpoint/                     # Private Endpoint Module
│
└── environment/                              # Environment Directory
    └── dev/                                  # Development Environment
        ├── providers.tf
        ├── main.tf                           # Module invocations with depends_on
        ├── variables.tf                      # Variable definitions (rg-dev, vnet-dev, etc.)
        ├── terraform.tfvars                  # Clean map configurations matching diagram
        ├── terraform.tfvars.example
        └── outputs.tf                        # Outputs
```

---

## 🚀 How to Run

1. **Navigate to the dev environment:**
   ```bash
   cd environment/dev
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

## 🧪 DNS Resolution Test

Connect to the Linux VM and test the private connectivity:
```bash
ssh azureuser@<vm_public_ip>
nslookup <storage_account_name>.blob.core.windows.net
```
Resolves directly to:
```text
Name:   <storage_account_name>.privatelink.blob.core.windows.net
Address: 10.124.0.4
```
