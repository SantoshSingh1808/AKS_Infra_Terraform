resource "azurerm_resource_group" "sony_rg" {
  name     = "sony-rg"
  location = "southeastasia"
}

resource "azurerm_kubernetes_cluster" "sony_cluster" {
  name                = "sony-aks"
  location            = "southeastasia"
  resource_group_name = azurerm_resource_group.sony_rg.name
  dns_prefix          = "sonyaksdns"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "standard_a2_v2"
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
  name                = "sonyACR001" # globally unique
  resource_group_name = azurerm_resource_group.sony_rg.name
  location            = "southeastasia"
  sku                 = "Basic"
  admin_enabled       = true # only for dev/test
}

resource "azurerm_role_assignment" "sony_acr_pull" {
  depends_on           = [azurerm_container_registry.acr]
  principal_id         = azurerm_kubernetes_cluster.sony_cluster.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}
