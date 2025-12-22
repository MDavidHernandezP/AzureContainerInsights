resource "azurerm_dashboard" "aks" {
  name                = "aks-monitoring-dashboard"
  resource_group_name = var.resource_group_name
  location            = "global"
  dashboard_properties = file("${path.module}/../../dashboards/aks-dashboard.json")
}
