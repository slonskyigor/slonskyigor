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

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "apresstfchapter07"
  location = "australiasoutheast"
}

resource "azurerm_log_analytics_workspace" "la_workspace" {
  name                = "apresstflog"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_security_center_workspace" "defender" {
  scope        = data.azurerm_subscription.current.id
  workspace_id = azurerm_log_analytics_workspace.la_workspace.id
}

resource "azurerm_security_center_subscription_pricing" "pricing" {
  tier          = "Standard"
  resource_type = "Containers"
}

resource "azurerm_security_center_contact" "contact" {
  name  = "Igor Slonsky"
  email = "slonsky.igor@gmail.com"
  phone = "+40744123456"
  alert_notifications = true
  alerts_to_admins    = true
}

# resource "azurerm_security_center_auto_provisioning" "autoprovision" {
#   auto_provision = "On"
# }

resource "azurerm_subscription_policy_assignment" "va-auto-provisioning" {
  name                 = "mdc-autoprovisioning"
  display_name         = "Configure machines to receive a vulnerability assessment provider"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/13ce0167-8ca6-4048-8e6b-f996402e3c1b"
  subscription_id      = data.azurerm_subscription.current.id
  identity {
    type = "SystemAssigned"
  }
  location   = "East US"
  parameters = <<PARAMS
{ "vaType": { "value": "mdeTvm" } }
PARAMS
}

resource "azurerm_role_assignment" "va-auto-provisioning-identity-role" {
  scope              = data.azurerm_subscription.current.id
  role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/fb1c8493-542b-48eb-b624-b4c8fea62acd"
  principal_id       = azurerm_subscription_policy_assignment.va-auto-provisioning.identity[0].principal_id
}