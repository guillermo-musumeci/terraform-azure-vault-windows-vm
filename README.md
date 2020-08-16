# Deploy a Windows Server VM in Azure with HashiCorp Vault using Terraform

The code deploys a HashiCorp Vault in a Windows VM, with **Raft Integrated Storage**, and uses an **Azure KeyVault** for seal/unseal Vault keys.

## Instructions:

Deploy the VM using the Terraform code and then unseleal the Vault using the following code:

```
c:\vault\vault operator init -address=http://127.0.0.1:8200
```

> **Note:** this Terraform code is valid for **PoC** or **PoV** and NOT recommended for **Production** environments
