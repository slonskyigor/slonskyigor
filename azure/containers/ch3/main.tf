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
  name     = "ApressAzureTerraformCH03"
  location = "australiasoutheast"
}

resource "azurerm_container_registry" "acr" {
  name                = "apresstfacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Premium"
  admin_enabled       = true
  tags = {
    environment = "dev"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.identity.id
    ]
  }

  encryption {
    key_vault_key_id   = azurerm_key_vault_key.acrkey.id
    identity_client_id = azurerm_user_assigned_identity.identity.client_id
  }

  georeplications {
    location                = "Australia Central"
    zone_redundancy_enabled = false
    tags = {}
  }
}

data "azuread_client_config" "current" {}

data "azuread_service_principal" "serviceprincipal" {
  display_name = "acr-admin"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "azvault" {
  name                        = "apresstfkeyvaultnew"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
  sku_name                    = "premium"
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    # tenant_id    = data.azurerm_client_config.current.tenant_id
    # object_id    = data.azuread_service_principal.serviceprincipal.object_id
    key_permissions = [
      "List",
      "Get",
      "Create",
      "Delete",
      "Get",
      "Purge",
      "Recover",
      "Update",
      "GetRotationPolicy",
      "SetRotationPolicy",
      "WrapKey",
      "UnwrapKey"
    ]
    secret_permissions = [
      "Get",
      "List",
      "Set"
    ]
    storage_permissions = [
      "Get",
      "List",
      "Set"
    ]
  }

  access_policy {
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = data.azuread_service_principal.serviceprincipal.object_id
    key_permissions = [
      "List",
      "Get",
      "Create",
      "Delete",
      "Get",
      "Purge",
      "Recover",
      "Update",
      "GetRotationPolicy",
      "SetRotationPolicy",
      "WrapKey",
      "UnwrapKey"
    ]
  }
}

# resource "azurerm_key_vault_access_policy" "example-principal" {
#   key_vault_id = azurerm_key_vault.azvault.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   object_id    = data.azuread_service_principal.serviceprincipal.object_id
#   key_permissions = [
#     "List",
#     "Get",
#     "Create",
#     "Delete",
#     "Get",
#     "Purge",
#     "Recover",
#     "Update",
#     "GetRotationPolicy",
#     "SetRotationPolicy",
#     "WrapKey",
#     "UnwrapKey"
#   ]
#   depends_on = [
#     azurerm_key_vault.azvault
#   ]
# }

data "azurerm_key_vault" "azvault" {
  name                = azurerm_key_vault.azvault.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_key_vault_key" "acrkey" {
  name         = "acraccess"
  key_vault_id = data.azurerm_key_vault.azvault.id
  key_type     = "RSA"
  key_size     = 2048
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
    "unwrapKey"
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }
}

resource "azurerm_user_assigned_identity" "identity" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "acr-admin"
}

resource "random_integer" "random" {
  min = 1
  max = 20
}

resource "azurerm_service_plan" "appservice" {
  name                = "Linux"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S2"
}

resource "azurerm_linux_web_app" "webapp" {
  name                          = "ApressTFWebApp${random_integer.random.result}"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  service_plan_id               = azurerm_service_plan.appservice.id
  public_network_access_enabled = true
  https_only                    = true
  site_config {
    always_on           = "false"
    minimum_tls_version = "1.2"
    application_stack {
      docker_image_name        = var.acr_image
      docker_registry_url      = var.acr_server
      docker_registry_username = var.acruser
      docker_registry_password = var.acr_password
    }
  }
  app_settings = {
    "DOCKER_ENABLE_CI"     = "true"
    vnet_route_all_enabled = "true"
  }
}
