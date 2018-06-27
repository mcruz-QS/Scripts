resource "azurerm_resource_group" "prod" {
    name = "demo-terraform-azure"
    location = "SouthCentral US"

    tags {
        environment = "myLab"
    }
}

resource "azurerm_public_ip" "prod" {
name = "testPublicIp"
location = "SouthCentral US"
resource_group_name = "${azurerm_resource_group.prod.name}"
public_ip_address_allocation="dynamic"
tags {
        environment = "myLab"
    }
}


resource "azurerm_virtual_network" "prod" {
    name = "prod-network"
    address_space = ["10.0.0.0.0/16"]
    location = "SouthCentral US"
    resource_group_name = "${azurerm_resource_group.prod.name}"
}

resource "azurerm_subnet" "prod" {
    name = "tfsubnet"
    resource_group_name = "${azurerm_resource_group.prod.name}"
    virtual_network_name = "${azurerm_virtual_network.prod.name}"
    address_prefix = "10.0.2.0/24"
}

resource "azurerm_network_interface" "test" {
    name = "tfnet"
    location = "SouthCentral US"
    resource_group_name = "${azurerm_resource_group.prod.name}"

    ip_configuration {
        name = "ipaddr"
        subnet_id = "${azurerm_subnet.prod.name}"
        private_ip_address_allocation = "dynamic"
    }
}