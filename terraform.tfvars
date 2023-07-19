## VM config
vm = {
    "winVM1" = {
      name = "winVM1"
      size = "Standard_DS1_v2"
      storage_account_type = "StandardSSD_LRS"
      admin_username = "demousr"
      admin_password = "Password@123"
      # OS specs
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-Datacenter"
      version   = "latest"
    }
    # "winVM2" = {
    #   name = "winVM2"
    #   size = "Standard_DS1_v2"
    #   storage_account_type = "StandardSSD_LRS"
    #   admin_username = "demousr"
    #   admin_password = "Password@123"
    #   # OS specs
    #   publisher = "MicrosoftWindowsServer"
    #   offer     = "WindowsServer"
    #   sku       = "2022-Datacenter"
    #   version   = "latest"
    # }
}

## Firewall config

firewall_nat_rule = [ {
    name     = "firewall_Nat_rules"
    priority = 300
    action   = "Allow"
    rules = [
    {
            name = "rdp_access3"
            protocols = ["TCP"]
            source_addresses = ["83.221.156.201"]
            destination_addresses = "" # Firewall IP, Iac handles the fwpip.
            destination_ports = ["4001"]
            translated_address = "10.1.2.6"
            translated_port = 3389

    }
   ]
 } 
]

firewall_app_rule = [ {
  name = "firewall_app_rule"
  priority = 200
  action = "Action"
  rules = [ {
    name = "app_rule"
    source_addresses = ["10.6.1.4"]
    destination_fqdns = ["*.google.com", "*.microsoft.com"]
    protocols = [{
      port = "80"
      type = "Http"
    }]
  } ]
} ]

nsg_rules = [ 
  {
    name                       = "allowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "83.221.156.201"
    destination_address_prefix = "*"
  }
]