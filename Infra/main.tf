terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.33.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {

  }
  subscription_id = "9c2d44b8-0b58-4481-8de2-41223a92f641"
}

data "azurerm_resource_group" "aks_rg" {
  name = "sonu-rg"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "sonu-cluster"
  location            = "Malaysia West"
  resource_group_name = data.azurerm_resource_group.aks_rg.name
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

# data "azurerm_kubernetes_cluster" "aks_cluster" {
#   name                = "AKS_Ajay"
#   resource_group_name = data.azurerm_resource_group.aks_rg.name
# }

resource "azurerm_container_registry" "acr" {
  name                = "SonuACR001" # globally unique
  resource_group_name = data.azurerm_resource_group.aks_rg.name
  location            = "Malaysia West"
  sku                 = "Basic"
  admin_enabled       = true # only for dev/test
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  depends_on           = [azurerm_container_registry.acr]
  principal_id         = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}
