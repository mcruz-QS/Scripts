output "azurerm_public_ip" {
  value = "${azurerm_public_ip.prod.fqdn}"
  value = "${azurerm_public_ip.prod.name}"
}

output "azurerm_virtual_machine" {
  value = "${azurerm_virtual_machine.myterraformvm.name}"
}

output "azurerm_dns_cname_record" {
  value = "${azurerm_dns_cname_record.test.name}.${data.azurerm_dns_zone.test.name}"
}

/*
output "azurerm_public_ip2" {
     value = "${azurerm_public_ip.prod.ip_address}"
 }
*/

