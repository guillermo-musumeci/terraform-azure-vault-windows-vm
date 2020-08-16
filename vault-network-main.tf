##########################
## Vault Network - Main ##
##########################

# Create a resource group for Vault
resource "azurerm_resource_group" "vault-rg" {
  name     = "${var.prefix}-${var.environment}-vault-rg"
  location = var.location
  tags = {
    environment = var.environment
  }
}

# Create the Vault VNET
resource "azurerm_virtual_network" "vault-vnet" {
  name                = "${var.prefix}-${var.environment}-vault-vnet"
  address_space       = [var.vault-vnet-cidr]
  resource_group_name = azurerm_resource_group.vault-rg.name
  location            = azurerm_resource_group.vault-rg.location
  tags = {
    environment = var.environment
  }
}

# Create a subnet for Vault
resource "azurerm_subnet" "vault-subnet" {
  name                 = "${var.prefix}-${var.environment}-vault-subnet"
  address_prefixes     = [var.vault-subnet-cidr]
  virtual_network_name = azurerm_virtual_network.vault-vnet.name
  resource_group_name  = azurerm_resource_group.vault-rg.name
}

