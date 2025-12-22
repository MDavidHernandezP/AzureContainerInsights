resource "azurerm_application_insights_workbook" "aks" {
  name                = "aks-monitoring-workbook"
  resource_group_name = var.resource_group_name
  location            = var.location
  source_id           = var.law_id
  display_name        = "AKS Monitoring Workbook"
  data_json           = file("${path.module}/../../workbooks/aks-workbook.json")
}
