##########################
## Vault VM - Variables ##
##########################

variable "vault_version" {
  description = "Vault version to download and install"
  type        = string
  default     = "1.5.0"
}

variable "vault_vm_size" {
  type        = string
  description = "Size (SKU) of the virtual machine to create"
}

variable "vault_admin_username" {
  description = "Username for Vault administrator account"
  type        = string
  default     = ""
}

variable "vault_admin_password" {
  description = "Password for Vault administrator account"
  type        = string
  default     = ""
}



