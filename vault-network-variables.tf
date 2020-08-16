###############################
## Vault Network - Variables ##
###############################

variable "vault-vnet-cidr" {
  type        = string
  description = "The CIDR of the Vault VNET"
}

variable "vault-subnet-cidr" {
  type        = string
  description = "The CIDR for the Vault subnet"
}
