# Diagnostics Settings for the Azure Firewall, not part of the AVM

resource "azapi_resource" "firewall_diagnostics" {

  # Only create if a Log Analytics Workspace ID is provided
  count = var.log_analytics_workspace_id != "" ? 1 : 0

  type      = "microsoft.insights/diagnosticSettings@2021-05-01-preview"
  name      = "firewall-diagnostics-to-law"
  parent_id = module.connectivity.firewall_resource_ids.hub-gwc

  body = {
    properties = {
      logAnalyticsDestinationType = "Dedicated"
      workspaceId                 = var.log_analytics_workspace_id
      logs = [
        {
          categoryGroup = "allLogs"
          enabled       = true
        },
      ]
      metrics = [
        {
          category = "AllMetrics"
          enabled  = true
        },
      ]
    }
  }

}
