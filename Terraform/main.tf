resource "azurerm_resource_group" "prod" {
  name     = "demo2-terraform-azure"
  location = "${var.azure_location}"

  tags {
    environment = "myLab"
  }
}

resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  number  = false
}

resource "azurerm_virtual_network" "prod" {
  name                = "pnetwork"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.prod.name}"
}

resource "azurerm_subnet" "prod" {
  name                 = "psubnet"
  resource_group_name  = "${azurerm_resource_group.prod.name}"
  virtual_network_name = "${azurerm_virtual_network.prod.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "prod" {
  name                         = "PublicIp"
  location                     = "${var.azure_location}"
  resource_group_name          = "${azurerm_resource_group.prod.name}"
  public_ip_address_allocation = "dynamic"
  domain_name_label            = "${random_string.fqdn.result}"

  tags {
    environment = "testLab"
  }
}

resource "azurerm_network_security_group" "prod" {
  name                = "NSG"
  location            = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.prod.name}"

  /*
    security_rule {
        name                       = "default-allow-ssh"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        source_address_prefix      = "*"
        destination_port_range     = "22"
        destination_address_prefix = "*"
  }
*/

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "${var.austin_ip}"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "WinRM"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985-5986"
    source_address_prefix      = "${var.austin_ip}"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "WinRM_HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "${var.austin_ip}"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "${var.austin_ip}"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "RDP"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3399"
    source_address_prefix      = "${var.austin_ip}"
    destination_address_prefix = "*"
  }
  tags {
    environment = "myLab"
  }
}

##

##
data "azurerm_resource_group" "test" {
  name = "macfun-app"
}

data "azurerm_dns_zone" "test" {
  name                = "test4me.xyz"
  resource_group_name = "${data.azurerm_resource_group.test.name}"
}

resource "azurerm_dns_cname_record" "test" {
  name                = "test"
  zone_name           = "${data.azurerm_dns_zone.test.name}"
  resource_group_name = "${data.azurerm_resource_group.test.name}"
  ttl                 = 3600
  record              = "${azurerm_public_ip.prod.fqdn}"
}

##
resource "azurerm_network_interface" "prod" {
  name                      = "pNIC"
  location                  = "${var.azure_location}"
  resource_group_name       = "${azurerm_resource_group.prod.name}"
  network_security_group_id = "${azurerm_network_security_group.prod.id}"

  ip_configuration {
    name                          = "pIP"
    subnet_id                     = "${azurerm_subnet.prod.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.prod.id}"
  }

  tags {
    environment = "myLab"
  }
}

resource "random_id" "prod" {
  keepers = {
    resource_group = "${azurerm_resource_group.prod.name}"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
  name                     = "diag${random_id.prod.hex}"
  resource_group_name      = "${azurerm_resource_group.prod.name}"
  location                 = "${var.azure_location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    environment = "myLab"
  }
}

resource "azurerm_virtual_machine" "myterraformvm" {
  name                  = "myVMtest"
  location              = "${var.azure_location}"
  resource_group_name   = "${azurerm_resource_group.prod.name}"
  network_interface_ids = ["${azurerm_network_interface.prod.id}"]
  vm_size               = "Standard_B1s"

  storage_os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core-smalldisk"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myvm"
    admin_username = "azureuser"
    admin_password = "Password1234!"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = "true"
    provision_vm_agent        = "true"
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
  }

  tags {
    environment = "myLab"
  }
}

