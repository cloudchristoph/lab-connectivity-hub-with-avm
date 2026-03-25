# Lab: Connectivity Hub with Azure Verified Modules

This lab demonstrates how to deploy a production-ready Azure connectivity hub using [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/). It covers the full hub deployment including Azure Firewall, VPN Gateway, and Azure Bastion — all wired up via a single AVM pattern module — as well as a separate Terraform root module for managing Firewall Policy rules and IP Groups.

> **Blog post (German):** A full walkthrough and explanation of this lab is available here:
> [Hub Deployment mit Azure Verified Modules](https://christoph.vollmann.co/2026/03/hub-deployment-mit-azure-verified-modules/)

---

## Architecture Overview

The lab is split into two independent Terraform root modules that reflect a common real-world separation of concerns:

| Module            | Purpose                                                                         |
| ----------------- | ------------------------------------------------------------------------------- |
| `connectivity/`   | Deploys the hub VNet, Azure Firewall, VPN Gateway, Bastion, and Firewall Policy |
| `firewall-rules/` | Deploys IP Groups and Firewall Policy Rule Collection Groups                    |

The hub is deployed to **Germany West Central** (`germanywestcentral`) using the address space `10.20.0.0/23`.

### Deployed Resources (`connectivity/`)

| Resource                         | Details                                                           |
| -------------------------------- | ----------------------------------------------------------------- |
| Hub Virtual Network              | `10.20.0.0/23`                                                    |
| Azure Firewall                   | Standard tier, Force-Tunnel mode (`management_ip_enabled = true`) |
| Firewall Policy                  | DNS proxy enabled                                                 |
| VPN Gateway                      | `VpnGw1AZ`, no BGP                                                |
| Azure Bastion                    | File copy, IP connect, tunneling, shareable link enabled          |
| Resource Group (Hub)             | `rg-hub-network-gwc`                                              |
| Resource Group (Firewall Policy) | `rg-hub-firewallpolicy-gwc`                                       |

Subnet layout within `10.20.0.0/23`:

| Subnet                        | CIDR             | Purpose                            |
| ----------------------------- | ---------------- | ---------------------------------- |
| AzureFirewallSubnet           | `10.20.0.0/26`   | Azure Firewall                     |
| AzureFirewallManagementSubnet | `10.20.0.64/26`  | Firewall management (force-tunnel) |
| AzureBastionSubnet            | `10.20.1.192/26` | Azure Bastion                      |
| GatewaySubnet                 | `10.20.1.128/26` | VPN Gateway                        |

### Deployed Resources (`firewall-rules/`)

#### IP Groups

| Name                        | Address Space                 |
| --------------------------- | ----------------------------- |
| `ipgroup-oad-azurefirewall` | `10.3.1.0/24` – `10.3.5.0/24` |
| `ipgroup-onpremises`        | `10.1.0.0/16`                 |
| `ipgroup-cclab`             | `10.2.0.0/16`, `10.3.0.0/16`  |
| `ipgroup-webapp-demo`       | `10.2.10.0/24`                |

#### Application Rule Collection Group (priority 100)

| Rule                         | Source                      | Destination                                    | Action |
| ---------------------------- | --------------------------- | ---------------------------------------------- | ------ |
| `allow-outbound-web-traffic` | OAD + webapp-demo IP groups | `*` (HTTP/HTTPS)                               | Allow  |
| `allow-inbound-webapp-demo`  | On-premises + cclab         | `appsvc-webapp-demo.azurewebsites.net` (HTTPS) | Allow  |

#### Network Rule Collection Group (priority 200)

| Rule                           | Source       | Destination | Ports/Protocol   | Action |
| ------------------------------ | ------------ | ----------- | ---------------- | ------ |
| `allow-ping` (on-prem → cloud) | On-premises  | cclab       | ICMP             | Allow  |
| `allow-administrative-access`  | On-premises  | cclab       | TCP/UDP 22, 3389 | Allow  |
| `allow-ping` (cloud → on-prem) | cclab        | On-premises | ICMP             | Allow  |
| `allow-internet-ping`          | OAD firewall | `*`         | ICMP             | Allow  |

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) `~> 1.14.5`
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (authenticated via `az login`)
- An Azure subscription with sufficient quota for:
  - Azure Firewall Standard
  - VPN Gateway (`VpnGw1AZ`)
  - Azure Bastion Standard

---

## Usage

The two modules are deployed independently. Deploy `connectivity/` first, as `firewall-rules/` references the Firewall Policy created by it.

### 1. Deploy the Hub (`connectivity/`)

```bash
cd connectivity

terraform init
terraform plan
terraform apply
```

To enable Firewall diagnostic logs to a Log Analytics Workspace, pass the workspace resource ID:

```bash
terraform apply -var="log_analytics_workspace_id=/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<name>"
```

### 2. Deploy Firewall Rules (`firewall-rules/`)

```bash
cd firewall-rules

terraform init
terraform plan
terraform apply
```

---

## Remote State (Recommended for Production)

Both modules ship with a commented-out `backend "azurerm"` block. For any environment beyond a local lab, uncomment and configure it to store state in Azure Blob Storage with Entra ID authentication:

```hcl
backend "azurerm" {
  use_azuread_auth     = true
  storage_account_name = "<your-storage-account>"
  container_name       = "<your-container>"
  key                  = "connectivity.tfstate"   # or firewall-rules.tfstate
}
```

> **Note:** Never use local state files in shared or production environments.

---

## Provider Versions

| Provider            | Version   |
| ------------------- | --------- |
| `hashicorp/azurerm` | `~> 4.47` |
| `azure/azapi`       | `~> 2.4`  |

The `azapi` provider is used to manage resources not yet fully supported in `azurerm`, specifically:

- Firewall diagnostic settings (`microsoft.insights/diagnosticSettings`)
- Firewall Policy Rule Collection Groups
- IP Groups

---

## Module Reference

The connectivity hub is built on:

[`Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm`](https://registry.terraform.io/modules/Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm/latest) `v0.16.13`

This is an official AVM pattern module that implements the [Azure Landing Zone connectivity pattern](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/network-topology-and-connectivity) for Hub and Spoke networks.

---

## Related Resources

- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [AVM Pattern: ALZ Connectivity Hub and Spoke VNet](https://registry.terraform.io/modules/Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm/latest)
- [Azure Firewall documentation](https://learn.microsoft.com/azure/firewall/)
- [Azure Well-Architected Framework – Network topology](https://learn.microsoft.com/azure/well-architected/networking/)
- [Blog post: Hub Deployment mit Azure Verified Modules (German)](https://christoph.vollmann.co/2026/03/hub-deployment-mit-azure-verified-modules/)
