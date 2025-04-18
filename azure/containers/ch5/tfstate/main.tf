terraform {
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

resource "azurerm_resource_group" "tfstate" {
  name     = "tfstate"
  location = "westus"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstateazsi"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id  = azurerm_storage_account.tfstate.id
  container_access_type = "blob"
}
