# ----------------------------------------------------------------------------------------------
# --- ABOUT

# CREATED BY: Henry Gelderbloem
# VERSION: 1.0

# ----------------------------------------------------------------------------------------------
# --- Variables

# Resource Group
$rgLocation = "uksouth"
$rgName = "hub-$rgLocation-rg-01"

# Hub Virtual Network
$vnetName = "hub-$rgLocation-vnet-01"

# Azure Bastion
$nsgBastionName = "bastion-$rgLocation-snet-nsg"

# ----------------------------------------------------------------------------------------------
# --- Create Hub Resource Group

# Create Hub Resource Group
New-AzResourceGroup -Name $rgName -Location $rgLocation

# Confirm creation of Hub Resource Group
do {
    $rgProvisioningState = Get-AzResourceGroup -Name $rgName -ErrorAction Ignore | ForEach-Object {$_.ProvisioningState -eq  'succeeded'}
} until ($rgProvisioningState -eq 'True')

# Create Resource Group cannot delete lock
New-AzResourceLock -ResourceGroupName $rgName -LockLevel CanNotDelete -Name "Cannot delete $rgName" -LockNotes "Protects $rgName from deletion." -Force

# ----------------------------------------------------------------------------------------------
# --- Create Azure Bastion Network Secuirty Group

# Create Azure Bastion Network Security Group required rules
# Inbound Rules
$inboundFromAnyAllow = New-AzNetworkSecurityRuleConfig -Direction Inbound -SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 443 -Protocol Tcp -Access Allow -Priority 100 -Name InboundFromAnyAllow -Description "Allow connection from any host on https."

$inboundFromGMAllow = New-AzNetworkSecurityRuleConfig -Direction Inbound -SourceAddressPrefix GatewayManager -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 443,4443 -Protocol Tcp -Access Allow -Priority 120 -Name InboundFromGatewayManagerAllow -Description "Allow Gateway Manager connection to Azure Bastion host."       

$inboundFromAnyDeny = New-AzNetworkSecurityRuleConfig -Direction Inbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange * -Protocol * -Access Deny -Priority 900 -Name InboundFromAnyDeny -Description "Deny connection to Azure Bastion host."       

# Outbound Rules
$outboundSSHRDPAllow = New-AzNetworkSecurityRuleConfig -Direction Outbound -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix VirtualNetwork -DestinationPortRange 22,3389 -Protocol Tcp -Access Allow -Priority 100 -Name OutboundToVNET_SSH_RDP -Description "Allow connection to Virtual Machines over private IP on ssh and rdp."       

$outboundtoAzureCloud = New-AzNetworkSecurityRuleConfig -Name OutboundToAzureCloud_HTTPS -Direction Outbound -Description "Allow connection to other public endpoints in Azure on https." -Priority 120 -SourcePortRange * -DestinationPortRange 443 -Protocol Tcp -SourceAddressPrefix * -DestinationAddressPrefix AzureCloud -Access Allow

# Create Azure Bastion Network Security Group
$nsgBastion = New-AzNetworkSecurityGroup -ResourceGroupName $RGNAME -Location $RGLOCATION -Name $nsgBastionName -SecurityRules $inboundFromAnyAllow,$inboundFromGMAllow,$inboundFromAnyDeny,$outboundSSHRDPAllow,$outboundtoAzureCloud

# ----------------------------------------------------------------------------------------------
# --- Create Hub Virtual Network

# Create Subnet Configuration variables
# Create GatewaySubnet
$gatewaySubnet = New-AzVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix "10.1.0.0/27"

# Create AzureFirewallSubnet
$firewallSubnet = New-AzVirtualNetworkSubnetConfig -Name AzureFirewallSubnet -AddressPrefix "10.1.1.0/26"

# Create AzureBastionSubnet
$bastionSubnet = New-AzVirtualNetworkSubnetConfig -Name AzureBastionSubnet -AddressPrefix "10.1.2.0/27" -NetworkSecurityGroup $nsgBastion

# Create Hub Virtual Network
New-AzVirtualNetwork -ResourceGroupName $rgName -Name $vnetName -Location $rgLocation -AddressPrefix "10.1.0.0/16" -Subnet $gatewaySubnet,$firewallSubnet,$bastionSubnet