# Providers

provider "azure" {
    subscription_id = "${var.azure_subscription_id}"
    client_id  = "${var.azure_client_id}"
    client_secret = "${var.azure_client_secret}"
    tenant_id = "${var.azure_tenant_id}"
}

# Data

# data "azrm_availability_zones" "available" {}

# resource
resource "azurerm_resource_group" "default" {
    name        = "${var.azure_rg_name}"
    location    = "${var.azure_location[0]}"

    tags = {
        environment = "Develop"
        account  = "test4me"
    }
}
# Modules Networking

module "network" {
    source              = "Azure/network/azurerm"
    resource_group_name = "${azurerm_resource_group.default.name}"
    location            = "${var.azure_location[0]}"
    address_space       = "10.0.0.0/16"
    subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]
    subnet_names        = ["subnet1", "subnet2"]

    tags = {
        environment = "Develop"
        account  = "test4me"
    }
}

# Public IP
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "${var.azure_rg_name - "publicIP"}"
    location                     = "${var.azure_location[0]}"
    resource_group_name          = "${azurerm_resource_group.default.name}"
    public_ip_address_allocation = "dynamic"

    tags = {
        environment = "Develop"
        account  = "test4me"
    }
}

# Create NSG
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "${var.azure_rg_name - "NSG"}"
    location            = "${var.azure_location[0]}"
    resource_group_name = "${azurerm_resource_group.default.name}"

# need nsg for windows
    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Develop"
        account  = "test4me"
    }
sadklf
address_space{{}}
}
