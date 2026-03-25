resource "azapi_resource" "ipgroups" {
  for_each  = local.ip_groups
  type      = "Microsoft.Network/ipGroups@2025-03-01"
  name      = each.value.name
  location  = var.location
  parent_id = data.azapi_resource.rg_hub_fw_policy.id
  body = {
    properties = {
      ipAddresses = each.value.ip_addresses
    }
  }
}
