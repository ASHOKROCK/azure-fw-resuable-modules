resource "azurerm_resource_group" "vnet_rg" {
  name = var.resourcegroup_name
  location = var.location
  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  address_space = var.vnet_address_space
  location = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnet
  resource_group_name = var.resourcegroup_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  name = each.value["name"]
  address_prefixes =  each.value["address_prefixes"]
}



# resource "azurerm_public_ip" "bastion_pip" {
#   name = "${var.bastionhost_name}pip"
#   location = azurerm_resource_group.vnet_rg.location
#   resource_group_name = azurerm_resource_group.vnet_rg.name
#   allocation_method = "Static"
#   sku = "Standard"
#   tags = var.tags
# }

# resource "azurerm_bastion_host" "bastion" {
#   name = var.bastionhost_name
#   location = azurerm_resource_group.vnet_rg.location
#   resource_group_name = azurerm_resource_group.vnet_rg.name
#   tags = var.tags

#   ip_configuration {
#     name = "bastion_config"
#     subnet_id = azurerm_subnet.subnet["bastion_subnet"].id
#     public_ip_address_id = azurerm_public_ip.bastion_pip.id
#   }
# }

# Create virtual machine

resource "azurerm_public_ip" "vm_public_ip" {
  for_each = var.vm
  name                = "${each.value["name"]}pip"
  location = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  allocation_method   = "Dynamic"
}
# Create network interface
resource "azurerm_network_interface" "vm_public_nic" {
  for_each = var.vm
  name                = "${each.value["name"]}nic"
  location = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name

  ip_configuration {    
    name                          = "${each.value["name"]}ip_config"
    subnet_id                     = azurerm_subnet.subnet["subnet_2"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip[each.key].id
  }
}


resource "azurerm_windows_virtual_machine" "vm" {
  for_each = var.vm
  name                  = each.value["name"]
  location = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  network_interface_ids = [azurerm_network_interface.vm_public_nic[each.key].id]
  size                  = each.value["size"]
  admin_username                  = each.value["admin_username"]
  admin_password                  = each.value["admin_password"]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = each.value["storage_account_type"]
  }

  source_image_reference {
    publisher = each.value["publisher"]
    offer     = each.value["offer"]
    sku       = each.value["sku"]
    version   = each.value["version"]
  }
}

# resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
#   for_each = var.vm
#   name                       = "vm_extension_install_iis"
#   virtual_machine_id         = azurerm_windows_virtual_machine.vm[each.key].id
#   publisher                  = "Microsoft.Compute"
#   type                       = "CustomScriptExtension"
#   type_handler_version       = "1.9"
#   auto_upgrade_minor_version = true
#   settings = <<SETTINGS
#     {
#         "commandToExecute":"powershell -ExecutionPolicy Unrestricted Add-WindowsFeature Web-Server; powershell -ExecutionPolicy Unrestricted Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.html\" -Value $($env:computername)"
#     }
# SETTINGS
# }

resource "azurerm_network_security_group" "network_security_group" {
  name                = "test"
  location = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name

  dynamic "security_rule" {
    for_each = var.nsg_rules
    content {
      name                       = security_rule.value["name"]
      priority                   = security_rule.value["priority"]
      direction                  = security_rule.value["direction"]
      access                     = security_rule.value["access"]
      protocol                   = security_rule.value["protocol"]
      source_port_range          = security_rule.value["source_port_range"]
      destination_port_range     = security_rule.value["destination_port_range"]
      source_address_prefix      = security_rule.value["source_address_prefix"]
      destination_address_prefix = security_rule.value["destination_address_prefix"]
    }
  }
  tags = {
    environment = "Production"
  }
}