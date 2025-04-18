terraform {
  # backend "azurerm" {
  #   resource_group_name  = "chapter5remotestate"
  #   storage_account_name = "tfstate99h7p"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "97764cf6-4deb-4911-860a-e78e0ee331b2"
  use_cli         = true
}

resource "azurerm_resource_group" "rg" {
  name     = "ApressAzureTerraformCH05"
  location = "westus"
}

resource "azurerm_kubernetes_cluster" "akscluster" {
  name                = "aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks"
  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "standard_a2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
  tags = {
    Environment = "DEV"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = "apresstfacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled        = true
}

resource "azurerm_role_assignment" "role" {
  principal_id                     = azurerm_kubernetes_cluster.akscluster.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}