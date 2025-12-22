resource "azurerm_monitor_scheduled_query_rules_alert" "pods_down" {
  name                = "aks-pods-down"
  resource_group_name = var.resource_group_name
  location            = var.location
  data_source_id      = var.law_id
  severity            = 2
  frequency           = 5
  time_window         = 5

  query = <<KQL
KubePodInventory
| where PodStatus != "Running"
KQL

  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }
}
