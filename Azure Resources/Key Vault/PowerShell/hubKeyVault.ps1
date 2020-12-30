# ----------------------------------------------------------------------------------------------
# --- ABOUT

# CREATED BY: Henry Gelderbloem
# VERSION: 1.0

# ----------------------------------------------------------------------------------------------
# --- Variables

# Resource Group
$rgLocation = ""
$rgName = "hub-kv-prod-$rgLocation-rg-01"

# Hub Key Vault
$keyVaultName = "hub-$rgLocation-kv-td-01"

# ----------------------------------------------------------------------------------------------
# --- Create Hub Key Vault Resource Group

# Create Hub Key Vault Resource Group
New-AzResourceGroup -Name $rgName -Location $rgLocation

# Confirm creation of Hub Key Vault Resource Group
do {
    $rgProvisioningState = Get-AzResourceGroup -Name $rgName -ErrorAction Ignore | ForEach-Object {$_.ProvisioningState -eq  'succeeded'}
} until ($rgProvisioningState -eq 'True')

# Create Resource Group cannot delete lock
New-AzResourceLock -ResourceGroupName $rgName -LockLevel CanNotDelete -Name "Cannot delete $rgName" -LockNotes "Protects $rgName from deletion." -Force

# ----------------------------------------------------------------------------------------------
# --- Create Hub Key Vault

# Create Hub Key Vault
New-AzKeyVault -VaultName $keyVaultName -resourceGroupName $rgName -Location $rgLocation -EnabledForTemplateDeployment

# Set Hub Key Vault Access Policy
Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -UserPrincipalName 'hgelderbloem@icloud.com' -PermissionsToSecrets get,set,delete

# ----------------------------------------------------------------------------------------------
# --- Create Virtual Machine Local Administrator Key Vault Secret

# Create the Virtual Machine Secret
Add-Type -AssemblyName 'System.Web'
$vmPassword = [System.Web.Security.Membership]::GeneratePassword(16,4) | ConvertTo-SecureString -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name 'vmPassword' -SecretValue $vmPassword

# Create Hub Key Vault cannot edit lock
New-AzResourceLock -ResourceName $keyVaultName -ResourceType Microsoft.KeyVault/vaults -ResourceGroupName $rgName -LockLevel ReadOnly -LockName "Cannot edit $keyVaultName" -LockNotes "Protects $keyVaultName from changes." -Force