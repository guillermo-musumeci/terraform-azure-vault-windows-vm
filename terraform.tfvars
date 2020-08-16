####################
# Common Variables #
####################
company     = "kopicloud"
prefix      = "kopi"
environment = "dev"
location    = "northeurope"
description = "Deploy HashiCorp Vault on Azure"
owner       = "Guillermo Musumeci"

##################
# Authentication #
##################
azure-subscription-id = "complete-this"
azure-client-id       = "complete-this"
azure-client-secret   = "complete-this"
azure-tenant-id       = "complete-this"

###################
# Azure Key Vault #
###################
kv-full-object-id = "complete-this"
kv-read-object-id = "complete-this"

#################
# Vault Network #
#################
vault-vnet-cidr   = "10.10.0.0/16"
vault-subnet-cidr = "10.10.1.0/24"

############
# Vault VM #
############
vault_vm_size        = "Standard_B2s"
vault_admin_username = "vaultadmin"

################
# Vault Config #
################
vault_version = "1.5.0"
