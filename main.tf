resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "log_analytics" {
  source              = "./modules/log_analytics"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
}

module "aks" {
  source              = "./modules/aks"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  law_id              = module.log_analytics.workspace_id
}

module "alerts" {
  source              = "./modules/alerts"
  resource_group_name = azurerm_resource_group.rg.name
  law_id              = module.log_analytics.workspace_id
}

module "dashboard" {
  source              = "./modules/dashboard"
  resource_group_name = azurerm_resource_group.rg.name
}

module "workbook" {
  source              = "./modules/workbook"
  resource_group_name = azurerm_resource_group.rg.name
  law_id              = module.log_analytics.workspace_id
}

module "rbac" {
  source       = "./modules/rbac"
  scope        = azurerm_resource_group.rg.id
  principal_id = var.trainer_object_id
}
