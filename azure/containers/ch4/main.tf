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

resource "azurerm_resource_group" "rg" {
  name     = "ApressAzureTerraformCH04"
  location = "westus"
}

resource "azurerm_container_group" "acigroup" {
  name                = "ApressTerraform"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = "apressterraformbook"
  os_type             = "Linux"

  container {
    name = "container"
    # image  = var.acr_image
    image  = "mirror.gcr.io/httpd"
    cpu    = "1"
    memory = "1"
    ports {
      port     = 80
      protocol = "TCP"
    }
    volume {
      name       = "logs"
      mount_path = "/apress/logs"
      read_only  = false
      share_name = azurerm_storage_share.share.name
      storage_account_name = azurerm_storage_account.storageact.name
      storage_account_key  = azurerm_storage_account.storageact.primary_access_key
    }
  }

  diagnostics {
    log_analytics {
      workspace_id =  azurerm_log_analytics_workspace.log_analytics.workspace_id
      workspace_key = azurerm_log_analytics_workspace.log_analytics.primary_shared_key
    }
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_account" "storageact" {
  name                     = "apresstfch04storage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "share" {
  name               = "aci-apress-tf-share"
  storage_account_id = azurerm_storage_account.storageact.id
  quota              = 50
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "apresstfch04storagelogs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}