#######################
## Vault VM - Output ##
#######################

output "vault_vm_name" {
  description = "Vault VM name"
  value       = azurerm_windows_virtual_machine.vault-vm.name
}

output "vault_vm_ip_address" {
  description = "Vault VM IP Address"
  value       = azurerm_public_ip.vault-vm-ip.ip_address
}

output "vault_vm_admin_username" {
  description = "Administrator Username for the Vault VM"
  value       = var.vault_admin_username
  #sensitive   = true
}

output "vault_vm_admin_password" {
  description = "Administrator Password for the Vault VM"
  value       = random_password.vaultadmin-password.result
  #sensitive   = true
}

output "vault_config_debug" {
  description = "Vault Config DEBUG"
  value       = data.template_file.vault-config.rendered
  #sensitive   = true
}
