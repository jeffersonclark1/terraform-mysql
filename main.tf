resource "azurerm_resource_group" "es21" {
  name     = "es21-resources"
  location = "eastus"
}

provider "azurerm" {
  skip_provider_registration = false
  features {}
}

resource "azurerm_mysql_server" "es21" {
  name                = "es21-mysqlserver"
  location            = azurerm_resource_group.es21.location
  resource_group_name = azurerm_resource_group.es21.name

  administrator_login          = "mysqladminun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
}

resource "azurerm_mysql_firewall_rule" "es21" {
  name                = "office"
  resource_group_name = azurerm_resource_group.es21.name
  server_name         = azurerm_mysql_server.es21.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}