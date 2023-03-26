# Valores de salida de Terraform

#Resource Group ID
output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

#VM ID
output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}

#Public IP
output "vip" {
  value = azurerm_public_ip.pip.ip_address
}
