#############################
## Key Vault Module - Main ##
#############################

# Azure Client Config
data "azurerm_client_config" "current" {}

# Create the Azure Key Vault - globally unique - 24 characters max
resource "azurerm_key_vault" "key-vault" {
  name                = "${var.prefix}-${var.environment}-vault-kv"
  location            = azurerm_resource_group.vault-rg.location
  resource_group_name = azurerm_resource_group.vault-rg.name
  
  enabled_for_deployment          = var.kv-enabled-for-deployment
  enabled_for_disk_encryption     = var.kv-enabled-for-disk-encryption
  enabled_for_template_deployment = var.kv-enabled-for-template-deployment

  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name  = var.kv-sku-name

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = {
    application = "HashiCorp Vault"
    environment = var.environment 
  }
}

# Create a Default Azure Key Vault access policy with Admin permissions
# This policy must be kept for a proper run of the "destroy" process
resource "azurerm_key_vault_access_policy" "default_policy" {
  depends_on=[azurerm_key_vault.key-vault]

  key_vault_id = azurerm_key_vault.key-vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  lifecycle {
    create_before_destroy = true
  }

  key_permissions         = var.kv-key-permissions-full
  secret_permissions      = var.kv-secret-permissions-full
  certificate_permissions = var.kv-certificate-permissions-full
  storage_permissions     = var.kv-storage-permissions-full
}

# Create a Full policy
resource "azurerm_key_vault_access_policy" "full-policy" {
  depends_on=[azurerm_key_vault.key-vault]

  key_vault_id = azurerm_key_vault.key-vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.kv-full-object-id

  lifecycle {
    create_before_destroy = true
  }

  key_permissions         = var.kv-key-permissions-full
  secret_permissions      = var.kv-secret-permissions-full
  certificate_permissions = var.kv-certificate-permissions-full
  storage_permissions     = var.kv-storage-permissions-full
}

# Create Read policy
resource "azurerm_key_vault_access_policy" "read-policy" {
  depends_on=[azurerm_key_vault.key-vault]

  key_vault_id = azurerm_key_vault.key-vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.kv-read-object-id

  lifecycle {
    create_before_destroy = true
  }

  key_permissions         = var.kv-key-permissions-read
  secret_permissions      = var.kv-secret-permissions-read
  certificate_permissions = var.kv-certificate-permissions-read
  storage_permissions     = var.kv-storage-permissions-read
}

# Create a Key Vault Key for Vault
resource "azurerm_key_vault_key" "vault-key" {
 depends_on=[
    azurerm_key_vault.key-vault, 
    azurerm_key_vault_access_policy.default_policy,
    azurerm_key_vault_access_policy.full-policy,
    azurerm_key_vault_access_policy.read-policy
  ]
  
  name         = "${var.prefix}-${var.environment}-vault-key"
  key_vault_id = azurerm_key_vault.key-vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

