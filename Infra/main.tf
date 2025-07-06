resource "azurerm_resource_group" "sonu_rg" {
  name     = "sonu-rg"
  location = "Malaysia West"
}

resource "azurerm_kubernetes_cluster" "sonu_cluster" {
  name                = "sonu-cluster"
  location            = "Malaysia West"
  resource_group_name = azurerm_resource_group.sonu_rg.name
  dns_prefix          = "sonuaksdns"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }


  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "SonuACR001" # globally unique
  resource_group_name = azurerm_resource_group.sonu_rg.name
  location            = "Malaysia West"
  sku                 = "Basic"
  admin_enabled       = true # only for dev/test
}

resource "azurerm_role_assignment" "sonu_acr_pull" {
  depends_on           = [azurerm_container_registry.acr]
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}
