resource "azurerm_resource_group" "prod101" {
  name     = "rg-production"
  location = "australiasoutheast"
}

resource "azurerm_resource_group" "dev101" {
  provider = azurerm.Development
  name     = "rg-development"
  location = "australiasoutheast"
}