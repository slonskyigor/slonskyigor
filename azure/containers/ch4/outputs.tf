data "azurerm_container_group" "acigroup" {
  name                = azurerm_container_group.acigroup.name
  resource_group_name = azurerm_resource_group.rg.name
}

output "fqdn" {
  value = azurerm_container_group.acigroup.fqdn
}

output "id" {
  value = azurerm_container_group.acigroup.id
}

output "ip_address" {
  value = data.azurerm_container_group.acigroup.ip_address
}

output "zones" {
  value = data.azurerm_container_group.acigroup.zones
}

output "tags" {
  value = data.azurerm_container_group.acigroup.tags
}