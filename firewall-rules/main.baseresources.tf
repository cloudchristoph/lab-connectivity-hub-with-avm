data "azapi_resource" "rg_hub_fw_policy" {
  type = "Microsoft.Resources/resourceGroups@2025-04-01"
  name = "rg-hub-firewallpolicy-gwc"
}

data "azapi_resource" "hub_fw_policy" {
  type      = "Microsoft.Network/firewallPolicies@2025-05-01"
  name      = "fwp-hub-germanywestcentral-001"
  parent_id = data.azapi_resource.rg_hub_fw_policy.id
}
