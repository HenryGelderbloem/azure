What does a DC need

Know - General Stuff
Resource Group
Key Vault
Lock

Resource Group
Recovery Services Vault
DC Backup Policy
Lock

Resource Group
Azure Update Management
Lock


Know - DC stuff
Resource Group - Name, Location , Tags w/inheritance
NSG - RG, Name, Location
ADDS NSG Rules - RG, NSG Name, Location, Rules
Subnet - RG, VNET Name, Address Prefix, NSG Name
VM - RG, Name, Location, Av Zone, Image, Size, User & Pass from Key Vault, 
	OS Disk Type, Encryption Type, Data Disk Type & Size + Cachine Disabled, 
	Virtual Network Name, Subnet Name, No Public IP, NSG for NIC, 
	Boot Diagnostics Enabled,  
Modify VNET DNS Server to DC
Lock

 
Don't know
monitoring - What to monitor for DCs
DSC - Install ADDS Server Roles
Proximity Placement Group Everything in same zone = same prosimity Placement Group
Tags (RG Level?) - Name: deploymentVersion 
	   Value: = $TemplateVersion

	   Name: deployedOn
	   Value: $Today()
	   
	   Name: env
	   Value: prod

	   Name: dep
	   Value: org

	   Name: criticality
	   Value: critical

	   Name: maintenanceWindow
	   Value: Sat:04:00-Sat:05:00
