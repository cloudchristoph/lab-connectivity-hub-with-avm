resource "azapi_resource" "application_rule_collection_group" {
  type      = "Microsoft.Network/firewallPolicies/ruleCollectionGroups@2025-03-01"
  name      = "cclab-application-rule-collection-group"
  parent_id = data.azapi_resource.hub_fw_policy.id
  body = {
    properties = {
      priority = 100
      ruleCollections = [
        {
          name               = "outbound-access-demo-app-rules"
          ruleCollectionType = "FirewallPolicyFilterRuleCollection"
          priority           = 100
          action = {
            type = "Allow"
          }
          rules = [
            {
              name        = "allow-outbound-web-traffic"
              description = "Allow outbound web traffic to the Internet"
              ruleType    = "ApplicationRule"
              sourceIpGroups = [
                azapi_resource.ipgroups["oad_azurefirewall"].id,
                azapi_resource.ipgroups["webapp_demo"].id
              ]
              targetFqdns = ["*"]
              protocols = [
                {
                  protocolType = "Http"
                  port         = 80
                },
                {
                  protocolType = "Https"
                  port         = 443
                }
              ]
            },
            {
              name        = "allow-inbound-webapp-demo"
              description = "Allow inbound traffic from internal networks to the webapp demo"
              ruleType    = "ApplicationRule"
              sourceIpGroups = [
                azapi_resource.ipgroups["on_premises"].id,
                azapi_resource.ipgroups["cclab"].id
              ]
              targetFqdns = ["appsvc-webapp-demo.azurewebsites.net"]
              protocols = [
                {
                  protocolType = "Https"
                  port         = 443
                }
              ]
            }
          ]
        }
      ]
    }
  }
}


resource "azapi_resource" "network_rule_collection_group" {
  type      = "Microsoft.Network/firewallPolicies/ruleCollectionGroups@2025-03-01"
  name      = "cclab-network-rule-collection-group"
  parent_id = data.azapi_resource.hub_fw_policy.id
  body = {
    properties = {
      priority = 200
      ruleCollections = [
        {
          name               = "onprem-to-cloud"
          ruleCollectionType = "FirewallPolicyFilterRuleCollection"
          priority           = 100
          action = {
            type = "Allow"
          }
          rules = [
            {
              name                = "allow-ping"
              description         = "Allow ICMP ping from on-premises to Azure resources"
              ruleType            = "NetworkRule"
              sourceIpGroups      = [azapi_resource.ipgroups["on_premises"].id]
              destinationIpGroups = [azapi_resource.ipgroups["cclab"].id]
              destinationPorts    = ["*"]
              ipProtocols         = ["ICMP"]
            },
            {
              name                = "allow-administrative-access"
              description         = "Allow administrative access from on-premises to Azure resources"
              ruleType            = "NetworkRule"
              sourceIpGroups      = [azapi_resource.ipgroups["on_premises"].id]
              destinationIpGroups = [azapi_resource.ipgroups["cclab"].id]
              destinationPorts    = ["22", "3389"]
              ipProtocols         = ["TCP", "UDP"]
            }
          ]
        },
        {
          name               = "cloud-to-onprem"
          ruleCollectionType = "FirewallPolicyFilterRuleCollection"
          priority           = 110
          action = {
            type = "Allow"
          }
          rules = [
            {
              name                = "allow-ping"
              description         = "Allow ICMP ping from Azure resources to on-premises"
              ruleType            = "NetworkRule"
              sourceIpGroups      = [azapi_resource.ipgroups["cclab"].id]
              destinationIpGroups = [azapi_resource.ipgroups["on_premises"].id]
              destinationPorts    = ["*"]
              ipProtocols         = ["ICMP"]
            }
          ]
        },
        {
          name               = "outbound-access-demo"
          ruleCollectionType = "FirewallPolicyFilterRuleCollection"
          priority           = 200
          action = {
            type = "Allow"
          }
          rules = [
            {
              name                 = "allow-internet-ping"
              description          = "Allow outbound ICMP ping to the Internet"
              ruleType             = "NetworkRule"
              sourceIpGroups       = [azapi_resource.ipgroups["oad_azurefirewall"].id]
              destinationAddresses = ["*"]
              destinationPorts     = ["*"]
              ipProtocols          = ["ICMP"]
            }
          ]
        }
      ]
    }
  }
}
