<# Init Log #>;
Start-Transcript -Path 'C:/Script/terraform-vault.txt' -append;
<#$DebugPreference = 'Continue' #>;
$VerbosePreference = 'Continue';
$InformationPreference = 'Continue';

<# Install Google Chrome #>;
$Installer = $env:TEMP + "\chrome_installer.exe"; 
Invoke-WebRequest "http://dl.google.com/chrome/install/375.126/chrome_installer.exe" -OutFile $Installer; 
Start-Process -FilePath $Installer -Args "/silent /install" -Verb RunAs -Wait; 
Remove-Item $Installer;

# Create the Vault folder #>;
$vaultPath = "C:\Vault";
mkdir $vaultPath;

<# Create the Vault Raft folder #>;
$raftPath = "C:\\Raft";
mkdir $raftPath;

<# Download Vault from HashiCorp site #>;
$vaultVersion = "${vault_version}"
$vaultFile = "vault_" + $vaultVersion + "_windows_amd64.zip";
$vaultURL = "https://releases.hashicorp.com/vault/" + $vaultVersion + "/" + $vaultFile;
$vaultOutFile = $vaultPath + "\" + $vaultFile;
Invoke-WebRequest -Uri $vaultURL -OutFile $vaultOutFile -UseBasicParsing;

<# Extract the content of the .zip file to the Vault folder #>;
Expand-Archive -LiteralPath $vaultOutFile -DestinationPath $vaultPath -force;

<# Create a local user #>;
$Password = ConvertTo-SecureString "${vault_password}" -AsPlainText -Force;
New-LocalUser -Name "vault" -Description "Vault account" -AccountNeverExpires -PasswordNeverExpires -Password $Password;

<# Create Vault Config File #>;
$vaultConfigFile = $vaultPath + "\vault.hcl";
New-Item $vaultConfigFile;

Set-Content $vaultConfigFile @"
seal "azurekeyvault" {
  client_id      = "${client_id}"
  client_secret  = "${client_secret}"
  tenant_id      = "${tenant_id}"
  vault_name     = "${keyvault_name}"
  key_name       = "${key_name}"
}
storage "raft" {
  path = "$raftPath"
  node_id = "raft_node_1"
}
listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 1
}
api_addr = "http://${vault_address}:8200"
cluster_addr = "http://${vault_address}:8201"
ui=true
disable_mlock = true
"@;

<# Download NSSM #>;
$fileNSSM = $vaultPath + "\nssm-2.24.zip";
Invoke-WebRequest -Uri "http://nssm.cc/release/nssm-2.24.zip" -OutFile $fileNSSM;
Expand-Archive -LiteralPath $fileNSSM -DestinationPath $vaultPath -force;
Remove-Item $fileNSSM;

<# Create a Vault Service with NSSM #>;
$nssm = $vaultPath + "\nssm-2.24\win64\nssm.exe";
.$nssm install Vault ($vaultPath + "\vault.exe") server -config="$vaultConfigFile";
.$nssm start Vault;
