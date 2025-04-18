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
  use_cli = true
}

resource "azurerm_resource_group" "rg" {
  name     = "ApressAzureTerraformCH02"
  location = "Westus2"
}

resource "azurerm_service_plan" "appservice" {
  name                = "Linux"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "ApressTFWebApp${random_integer.random.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.appservice.id
  public_network_access_enabled = false
  https_only = true
  site_config {
    always_on = "false"
    minimum_tls_version = "1.2"
    application_stack {
      docker_image_name   = "httpd:latest"
      docker_registry_url = "https://index.docker.io"
    }
  }  app_settings = {
    "DOCKER_ENABLE_CI" = "true"
    vnet_route_all_enabled = "true"
  }
}

resource "random_integer" "random" {
  min = 1
  max = 20
}

resource "azurerm_subnet" "webappssubnet" {
  name                 = "webappssubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.azvnet.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet" "privatesubnet" {
  name                 = "privatesubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.azvnet.name
  address_prefixes     = ["10.0.2.0/24"]
  private_link_service_network_policies_enabled = true
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnetintegrationconnection" {
  app_service_id  = azurerm_linux_web_app.webapp.id
  subnet_id       = azurerm_subnet.webappssubnet.id
}

resource "azurerm_private_dns_zone" "dnsprivatezone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnszonelink" {
  name = "dnszonelink"
  resource_group_name = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dnsprivatezone.name
  virtual_network_id = azurerm_virtual_network.azvnet.id
}

resource "azurerm_private_endpoint" "privateendpoint" {
  name = "backwebappprivateendpoint"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id = azurerm_subnet.privatesubnet.id
  private_dns_zone_group {
    name = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.dnsprivatezone.id]
  }
  private_service_connection {
    name = "privateendpointconnection"
    private_connection_resource_id = azurerm_linux_web_app.webapp.id
    subresource_names = ["sites"]
    is_manual_connection = false
  }
}

resource "azurerm_virtual_network" "azvnet" {
  name                = "Vnet-WebAPP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}
