# ----------------------------------------------------------------------------------------------
# --- ABOUT

# CREATED BY: Henry Gelderbloem
# VERSION: 1.0

# ----------------------------------------------------------------------------------------------
# --- Variables

# Resource Group Location
$rgLocation = Read-Host -Prompt "Enter the Resource Group location"

# Resource Group Name
$rgName = "prod-adds-$rgLocation-rg-01"

# ----------------------------------------------------------------------------------------------
# --- Create AD DS Resource Group

# Create AD DS Resource Group
New-AzResourceGroup -Name $rgName -Location $rgLocation

# Confirm creation of AD DS Resource Group
do {
    $rgProvisioningState = Get-AzResourceGroup -Name $rgName -ErrorAction Ignore | ForEach-Object {$_.ProvisioningState -eq  'succeeded'}
} until ($rgProvisioningState -eq 'True')

# Create Resource Group cannot delete lock
New-AzResourceLock -ResourceGroupName $rgName -LockLevel CanNotDelete -Name "Cannot delete $rgName" -LockNotes "Protects $rgName from deletion." -Force