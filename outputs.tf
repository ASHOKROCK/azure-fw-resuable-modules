output "azure_subnet_id" {
  value = {
    for id in keys(var.subnet) : id => azurerm_subnet.subnet[id].id
  }
  description = "list of subnet id's"
}

# output "bastion_pip" {
#   value = azurerm_public_ip.bastion_pip.ip_address
#   description = "List the public ip of the bastion server"
# }

output "azure_vm_pip" {
  value = {
    for pip in keys(var.vm) : pip => azurerm_public_ip.vm_public_ip[pip].ip_address
  }
}

# azurerm_windows_virtual_machine.vm.private_ip_address

output "azure_vm_private" {
  value = {
    for vm_private_ip in keys(var.vm) : vm_private_ip => azurerm_windows_virtual_machine.vm[vm_private_ip].private_ip_address
  }
}