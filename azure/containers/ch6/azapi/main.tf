terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    azapi = {
      source = "Azure/azapi"
    }
  }
}
provider "azurerm" {
  subscription_id = "97764cf6-4deb-4911-860a-e78e0ee331b2"
  features {}
}
provider "azapi" {
  subscription_id = "97764cf6-4deb-4911-860a-e78e0ee331b2"
}

resource "azurerm_resource_group" "rg" {
  name     = "apresstfchapter06"
  location = "australiasoutheast"
}

resource "azapi_resource" "acr" {
  type      = "Microsoft.ContainerRegistry/registries@2023-01-01-preview"
  name      = "apressacr"
  parent_id = azurerm_resource_group.rg.id
  location = azurerm_resource_group.rg.location
  body = {
    sku = {
      name = "Standard"
    }
    properties = {
      adminUserEnabled = true
    }
  }
  tags = {
    "Key" = "DEV"
  }
  response_export_values = ["properties.loginServer", "properties.policies.quarantinePolicy.status"]
}

output "login_server" {
  value = azapi_resource.acr.output.properties.loginServer
}

