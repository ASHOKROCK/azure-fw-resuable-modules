resource "azurerm_public_ip" "fw-pip" {
  # for_each            = local.public_ip_map
  name                = "fw_pip"
  location = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "firewall_policy" {
  name                = "firewall_policy"
  location = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
}

resource "azurerm_firewall" "azure_fw" {
  name                = lower("azureFW")
  location = azurerm_resource_group.vnet_rg.location
  resource_group_name = azurerm_resource_group.vnet_rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  threat_intel_mode   = "Alert"
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  ip_configuration {
    name                 = "firewall-ip-config"
    subnet_id            = azurerm_subnet.subnet["firewall_subnet"].id
    public_ip_address_id = azurerm_public_ip.fw-pip.id
  }
}

# #----------------------------------------------
# # Azure Firewall Network/Application/NAT Rules 
# #----------------------------------------------

resource "azurerm_firewall_policy_rule_collection_group" "firewall_policies" {
  name               = "example-fwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  priority           = 500

  dynamic "nat_rule_collection" {
    for_each = var.firewall_nat_rule
    content {
    name     = nat_rule_collection.value.name
    priority = 300
    action   = "Dnat"
    dynamic "rule" {
        for_each = nat_rule_collection.value.rules
        content {
            name                  = rule.value.name
            source_addresses      = rule.value.source_addresses
            # source_ip_groups      = rule.value.source_ip_groups
            destination_ports     = rule.value.destination_ports
            destination_address   = azurerm_public_ip.fw-pip.ip_address
            translated_address    = rule.value.translated_address
            translated_port       = rule.value.translated_port
            protocols             = rule.value.protocols
        }
      }
    }
  }
  dynamic "application_rule_collection" {
    for_each = var.firewall_app_rule
    content {
      name = "example-application-rule"
      priority = 500
      action = "Allow"
    dynamic "rule" {
      for_each = application_rule_collection.value.rules
      content {
        name = rule.value.name
        source_addresses = rule.value.source_addresses
        destination_fqdns = rule.value.destination_fqdns
        dynamic "protocols" {
          for_each = rule.value.protocols
          content {
            type = protocols.value.type
            port = protocols.value.port
          }
        }
      }
    }
  }
  }
}