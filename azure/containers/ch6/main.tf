terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  subscription_id = "97764cf6-4deb-4911-860a-e78e0ee331b2"
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "apresstfchapter06"
  location = "australiaeast"
}

resource "azurerm_key_vault" "azvault" {
  name                        = "keyvault06si"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    key_permissions = [
      "Get",
      "List",
    ]
    secret_permissions = [
      "Get",
      "List",
    ]
    storage_permissions = [
      "Get",
      "List",
    ]
  }
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = "ff271bc5-db9c-4ffc-9d11-6774aea71860"
    key_permissions = [
      "Get",
      "List",
    ]
    secret_permissions = [
      "Get",
      "List",
    ]
    storage_permissions = [
      "Get",
      "List",
    ]
  }
}
