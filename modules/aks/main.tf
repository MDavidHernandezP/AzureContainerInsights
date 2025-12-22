resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-monitoring-demo"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aksdemo"

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
    os_type    = "Linux"
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = var.law_id
  }

  network_profile {
    network_plugin = "azure"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "windows" {
  name                  = "winpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  os_type               = "Windows"
  mode                  = "User"
}
