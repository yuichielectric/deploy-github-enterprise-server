provider "azurerm" {
  version = "1.38.0"
}

variable "prefix" {
  type    = string
  default = "ghes"
}

variable "location" {
  type    = string
  default = "japaneast"
}

variable "ghes-version" {
  type    = string
  default = "2.20.0"
}

variable "ssh_public_key" {
  type    = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdpWKK9P//6nT+hI5s3d4y9fMM/5AYP9yl1i/3qWX/CsA1DXvA2+sqXL2j3s0ngx3vgXE+nNRXvCGTPlw1jotprqlsLijjhBH04uwzIfpFgp1ZY1xRaX1x3EfbyS7uEtsvhZ06ckbZREFk50SEKcMov7EIIWV5QH//143OwRna8RfKL5HAEF5prexTOZii0OC6a8QGZ9w1wDA3kZJdZGxp0W/cV+EhUNG9w+rdLSiO5op9vcr+65DKO0k+a03JD3S7mFBXe19POSVTKCWXzkxsB1SgT6Re/pJyBu7KKMTPtz6brstJlgGgiaNdJ9WDMuK+mFO074GBnl/2w99hqzGd yuichielectric@github.com"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "terraformbackend-resources"
    storage_account_name = "terraformbackendstoracct"
    container_name       = "terraformbackend-content"
    key                  = "terraform.tfstate"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}-ip-config"
    subnet_id                     = azurerm_subnet.internal.id
    public_ip_address_id          = azurerm_public_ip.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-security-group"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "main" {
  name                        = "${var.prefix}-security-rules"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  destination_port_ranges     = ["22", "25", "80", "122", "443", "8080", "8443", "9418"]
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS11_v2"

  storage_image_reference {
    publisher = "GitHub"
    offer     = "GitHub-Enterprise"
    sku       = "GitHub-Enterprise"
    version   = var.ghes-version
  }

  storage_os_disk {
    name              = "${var.prefix}-os-storage"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
    disk_size_gb      = "200"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/testadmin/.ssh/authorized_keys"
      key_data = var.ssh_public_key
    }
  }
}

resource "azurerm_managed_disk" "main" {
  name                 = "${var.prefix}-data.vhd"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 50
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  managed_disk_id    = azurerm_managed_disk.main.id
  virtual_machine_id = azurerm_virtual_machine.main.id
  lun                = "10"
  caching            = "ReadWrite"
}

output "public_ip" {
  value       = azurerm_public_ip.main.ip_address
  description = "The IP address of the GitHub Enterprise Server instance"
}
