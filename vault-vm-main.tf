#####################
## Vault VM - Main ##
#####################

# Create Network Security Group
resource "azurerm_network_security_group" "vault-vm-nsg" {
  depends_on=[azurerm_resource_group.vault-rg]

  name                = "${var.prefix}-${var.environment}-vault-nsg"
  location            = azurerm_resource_group.vault-rg.location
  resource_group_name = azurerm_resource_group.vault-rg.name

  security_rule {
    name                       = "RDP"
    description                = "Allow RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Vault"
    description                = "Vault"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8200"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Consul"
    description                = "Consul"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8500"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
  }
}

# Associate the web NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "vault-vm-nsg-association" {
  depends_on=[azurerm_resource_group.vault-rg]

  subnet_id                 = azurerm_subnet.vault-subnet.id
  network_security_group_id = azurerm_network_security_group.vault-vm-nsg.id
}

# Get a Static Public IP for TESTING ONLY
resource "azurerm_public_ip" "vault-vm-ip" {
  depends_on=[azurerm_resource_group.vault-rg]

  name                = "${var.prefix}-${var.environment}-vault-ip"
  location            = azurerm_resource_group.vault-rg.location
  resource_group_name = azurerm_resource_group.vault-rg.name
  allocation_method   = "Static"
  
  tags = { 
    environment = var.environment
  }
}

# Generate random password for the VaultAdmin account 
resource "random_password" "vaultadmin-password" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  number           = true
  special          = true
  override_special = "!@#$%&"
}

# Generate random password for the Vault Local account 
resource "random_password" "vault-password" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  number           = true
  special          = false
}

# Create Network Card for the VM
resource "azurerm_network_interface" "vault-nic" {
  depends_on=[azurerm_resource_group.vault-rg]

  name                = "${var.prefix}-${var.environment}-vault-nic"
  location            = azurerm_resource_group.vault-rg.location
  resource_group_name = azurerm_resource_group.vault-rg.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vault-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vault-vm-ip.id # Remove this line for security
  }

  tags = { 
    environment = var.environment
  }
}

# Vault Template File
data "template_file" "vault-config" {
  depends_on=[azurerm_key_vault.key-vault, azurerm_key_vault_key.vault-key]

  template = file("${path.module}/vault-config.ps1")

  vars = {
    tenant_id      = var.azure-tenant-id
    client_id      = var.azure-client-id
    client_secret  = var.azure-client-secret
    keyvault_name  = azurerm_key_vault.key-vault.name
    key_name       = azurerm_key_vault_key.vault-key.name
    vault_address  = azurerm_public_ip.vault-vm-ip.ip_address
    vault_password = random_password.vault-password.result
    vault_version  = var.vault_version
  }
}

# Create Vault VM
resource "azurerm_windows_virtual_machine" "vault-vm" {
  depends_on=[
    azurerm_network_interface.vault-nic,
    azurerm_key_vault.key-vault,
    azurerm_key_vault_key.vault-key
  ]

  name                  = "${var.prefix}-${var.environment}-vault-vm"
  location              = azurerm_resource_group.vault-rg.location
  resource_group_name   = azurerm_resource_group.vault-rg.name
  network_interface_ids = [azurerm_network_interface.vault-nic.id]
  size                  = var.vault_vm_size
  
  computer_name  = "vault-vm"
  admin_username = var.vault_admin_username
  admin_password = random_password.vaultadmin-password.result
 
  os_disk {
    name                 = "${var.prefix}-${var.environment}-vault-vm-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  enable_automatic_updates = true
  provision_vm_agent       = true

  tags = {
    environment = var.environment 
  }
}

# Vault VM extension - Run configuration Scripts
resource "azurerm_virtual_machine_extension" "vault-vm-extension" {
  depends_on=[azurerm_windows_virtual_machine.vault-vm]

  name                 = "${var.prefix}-${var.environment}-vault-vm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.vault-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"  
  settings = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.vault-config.rendered)}')) | Out-File -filepath setup.ps1\" && powershell -ExecutionPolicy Unrestricted -File setup.ps1"
  }
  SETTINGS

  tags = {
    description = var.description
    environment = var.environment
    owner       = var.owner  
  }
}