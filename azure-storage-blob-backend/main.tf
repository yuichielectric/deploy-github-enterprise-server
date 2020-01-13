provider "azurerm" {
  version = "1.38.0"
}

variable "prefix" {
  default = "terraformbackend"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "japaneast"
}

resource "azurerm_storage_account" "main" {
  name                     = "${var.prefix}storacct"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "main" {
  name                  = "${var.prefix}-content"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
