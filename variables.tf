variable "resourcegroup_name" {
  type = string
  description = "This is resourcegroup name"
  default = "iftest-rg" 
}

variable "location" {
  type = string
  description = "The region for the deployment"
  default = "centralindia"
}

variable "tags" {
  type = map(string)
  description = "Tags used for the deployment"
  default = {
    "Environment" = "Lab"
    "Owner" = "Sri"
  }
}

variable "vnet_name" {
  type = string
  description = "The name of the vnet"
  default = "VNetTest"
}

variable "vnet_address_space" {
  type = list(any)
  description = "the address space of vnet"
  default = [ "10.1.0.0/16" ]
}

variable "subnet" {
  type = map(any)
  default = {
    "subnet_1" = {
      name = "subnet_1"
      address_prefixes = ["10.1.1.0/24"]
    }
    "subnet_2" = {
      name = "subnet_2"
      address_prefixes = ["10.1.2.0/24"]
    }
    "subnet_3" = {
      name = "subnet_3"
      address_prefixes = ["10.1.3.0/24"]
    }
    "firewall_subnet" = {
      name = "AzureFirewallSubnet"
      address_prefixes = ["10.1.4.0/24"]
    }
  }
}

variable "bastionhost_name" {
  type = string
  description = "The name of the bastion host"  
  default = "BastionHost"
}

variable "vm" {
  type = map(object({
    name     = string
    size     = string
    storage_account_type = string
    admin_username = string
    admin_password = string
    publisher = string
    offer = string
    sku = string
    version = string
  }))
   default = {
     "vm1" = {
       name = "vm1"
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
   }
}

variable "firewall_nat_rule" {
  description = "Create a Nat rule collection"
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name                  = string,
      source_addresses      = list(string),
      # source_ip_groups      = list(string),
      destination_ports     = list(string),
      destination_addresses = string,
      translated_port       = number,
      translated_address    = string,
      protocols             = list(string)
    }))
  }))
   default = [
     {
       name     = "NatRuleCollection1"
       priority = 100
       action   = "Dnat"
       rules = [
         {
           name                  = "RedirectWeb"
           source_addresses      = ["*"]
           destination_ports     = ["80"]
           destination_addresses = ["20.219.250.43"] # Firewall public IP Address
           translated_port       = 80
           translated_address    = "10.10.1.4"
           protocols             = ["TCP"]
           source_ip_groups      = null
         }
       ]
     }
   ]
}

variable "firewall_app_rule" {
  description = "Create a Application rule"
  type = list(object({
    name      = string
    priority  = number
    action    = string
    rules      = list(object({
      name    = string
      protocols = list(object({
        port = string,
        type = string
      }))
      source_addresses  = list(string)
      destination_fqdns = list(string)
    }))
  }))
}

variable "nsg_rules" {
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
default = [
   {
  name       =   "vnetnsg"
  priority   =    100
  direction  =    "Inbound"
  access     =  "Allow"
  protocol   = "Tcp"
  source_port_range    = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  }
]
  
}
