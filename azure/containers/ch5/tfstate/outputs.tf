data "azurerm_storage_account" "storage" {
  name                = azurerm_storage_account.tfstate.name
  resource_group_name = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}