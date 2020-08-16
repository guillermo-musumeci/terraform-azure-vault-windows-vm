############################
## Vault Network - Output ##
############################

output "vault_rg" {
  value = azurerm_resource_group.vault-rg
}

output "vault_vnet" {
  value = azurerm_virtual_network.vault-vnet
}

output "vault_subnet" {
  value = azurerm_subnet.vault-subnet
}

