##############################################################################
# * HashiCorp Beginner's Guide to Using Terraform on Azure
# 
# This Terraform configuration will create the following:
#
# Resource group with a virtual network and subnet
# An Ubuntu Linux server running Apache

provider "azurerm" {
  version = "=1.44.0"
}

resource "azurerm_resource_group" "es21" {
  name     = "${var.resource_group}"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  location            = "eastus"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${azurerm_resource_group.es21.name}"
}

resource "azurerm_subnet" "es21" {
  name                 = "${var.prefix}subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.es21.name}"
  address_prefix       = "${var.subnet_prefix}"
}

# Security group to allow inbound access on port 80 (http) and 22 (ssh)
resource "azurerm_network_security_group" "tf-guide-sg" {
  name                = "${var.prefix}-sg"
  location            = "eastus"
  resource_group_name = "${azurerm_resource_group.es21.name}"

  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "${var.source_network}"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "${var.source_network}"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "es21" {
  name                = "${var.prefix}"
  location            = "eastus"
  resource_group_name = azurerm_resource_group.es21.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.es21.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "es21" {
  name                = "${var.prefix}ip"
  resource_group_name = "${azurerm_resource_group.es21.name}"
  location            = "eastus"
  allocation_method   = "Static"
}

resource "azurerm_virtual_machine" "es21" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.es21.location
  resource_group_name   = azurerm_resource_group.es21.name
  network_interface_ids = [azurerm_network_interface.es21.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

##############################################################################
# * Azure MySQL Database

resource "azurerm_mysql_server" "es21" {
  name                = "mysql-server-es21"
  location            = azurerm_resource_group.es21.location
  resource_group_name = azurerm_resource_group.es21.name

  sku_name = "B_Gen5_2"

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = "mysqladminun"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "5.7"
  ssl_enforcement              = "Disabled"
}

resource "azurerm_mysql_database" "es21" {
  name                = "es21db"
  resource_group_name = azurerm_resource_group.es21.name
  server_name         = azurerm_mysql_server.es21.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_firewall_rule" "demo" {
  name                = "es21-demo"
  resource_group_name = "${azurerm_resource_group.es21.name}"
  server_name         = "${azurerm_mysql_server.es21.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}