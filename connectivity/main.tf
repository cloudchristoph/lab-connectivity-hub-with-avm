locals {
  hub_address_prefix                = "10.20.0.0/23"
  subnet_firewall_prefix            = cidrsubnet(local.hub_address_prefix, 3, 0)
  subnet_firewall_management_prefix = cidrsubnet(local.hub_address_prefix, 3, 1)
  subnet_bastion_prefix             = cidrsubnet(local.hub_address_prefix, 3, 6)
  subnet_gateway_prefix             = cidrsubnet(local.hub_address_prefix, 3, 7)
}

module "connectivity" {
  source  = "Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm"
  version = "0.16.13"

  hub_and_spoke_networks_settings = {
    enabled_resources = {
      ddos_protection_plan = false
    }
  }

  hub_virtual_networks = {
    gwc = {
      location = "germanywestcentral"

      default_parent_id = azurerm_resource_group.hub.id

      enabled_resources = {
        firewall                              = true
        firewall_policy                       = true
        virtual_network_gateway_vpn           = true
        virtual_network_gateway_express_route = false
        bastion                               = true
        private_dns_zones                     = false
        private_dns_resolver                  = false
      }

      hub_virtual_network = {
        address_space = [local.hub_address_prefix]
      }

      firewall = {
        subnet_address_prefix            = local.subnet_firewall_prefix
        management_subnet_address_prefix = local.subnet_firewall_management_prefix
        sku_name                         = "AZFW_VNet"
        sku_tier                         = "Standard"
        management_ip_enabled            = true
      }

      firewall_policy = {
        resource_group_name = azurerm_resource_group.firewall_policy.name
        dns = {
          proxy_enabled = true
          servers       = []
        }
      }

      virtual_network_gateways = {
        subnet_address_prefix                      = local.subnet_gateway_prefix
        route_table_creation_enabled               = true
        route_table_gateway_firewall_route_enabled = false
        vpn = {
          sku             = "VpnGw1AZ"
          vpn_bgp_enabled = false
        }
      }

      bastion = {
        subnet_address_prefix = local.subnet_bastion_prefix
        zones                 = []
        bastion_public_ip = {
          zones = []
        }
        file_copy_enabled      = true
        copy_paste_enabled     = true
        ip_connect_enabled     = true
        tunneling_enabled      = true
        shareable_link_enabled = true
      }

    }
  }
}

resource "azurerm_resource_group" "hub" {
  name     = "rg-hub-network-gwc"
  location = "germanywestcentral"
}

resource "azurerm_resource_group" "firewall_policy" {
  name     = "rg-hub-firewallpolicy-gwc"
  location = "germanywestcentral"
}
