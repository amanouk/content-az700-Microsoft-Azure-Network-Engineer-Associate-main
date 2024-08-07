###############################
####### SCRIPT DETAILS ########
# Intended Purpose: Setup environment for Azure Cloud 
# Disclaimer: This script is intended to be used only in an Azure Cloud Training Lab
# Message: To use this script for other Azure Cloud Sandbox environments
#       1.) Create your own resource group variable.
#       2.) Comment out variable in variables section.
#       3.) Uncomment below commands and assign your own resource group and location.
# rg=your-resource-group-here
# location=your-location-here
###############################

##############################
##### START - VARIABLES ######
##############################

# Create a Resource Group 
az group create --name brandrg --location eastus

# Get resource group and set to variable $rg
$rg = "brandrg"

# Assign location variable to playground resource group location
$location = az group list --query '[].location' -o tsv

##############################
##### END - VARIABLES ######
##############################

##############################
####### START - SCRIPT #######
##############################

## SETUP MAIN HUB VNET
# Create main hub vnet
az network vnet create --name "brand-hub-vnet-01" --resource-group $rg --location $location --address-prefixes 10.60.0.0/16 --subnet-name hub-subnet-01 --subnet-prefix 10.60.0.0/24

## SETUP SPOKE 1 VNET
# Create spoke 1 vnet
az network vnet create --name "brand-spoke1-vnet-01" --resource-group $rg --location $location --address-prefixes 10.120.0.0/16 --subnet-name spoke1-subnet-01 --subnet-prefix 10.120.0.0/24

## SETUP SPOKE 2 VNET
# Create spoke 2 vnet
az network vnet create --name "brand-spoke2-vnet-01" --resource-group $rg --location $location --address-prefixes 172.32.0.0/16 --subnet-name spoke2-subnet-01 --subnet-prefix 172.32.0.0/24

## CREATE NETWORK SECURITY GROUP AND SSH ACCESS RULE
# Create a network security group
az network nsg create --name "brand-hub-vm-nsg" --resource-group $rg --location $location

# Create a security rule to allow SSH traffic
az network nsg rule create --nsg-name "brand-hub-vm-nsg" --resource-group $rg --name "AllowSSH" --protocol Tcp --priority 1000 --destination-port-range 22 --access Allow --direction Inbound

## CREATE THE VM IN THE HUB VNET
# Create a public IP for the VM with Standard SKU without zone redundancy
az network public-ip create --name "brand-hub-vm-pip" --resource-group $rg --location $location --sku Standard --allocation-method Static

# Create the VM and specify the NSG and public IP
az vm create --resource-group $rg --name "brand-hub-vm-01" --location $location --vnet-name "brand-hub-vnet-01" --subnet "hub-subnet-01" --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --public-ip-address "brand-hub-vm-pip" --nsg "brand-hub-vm-nsg"

## DELETE THE NSG THAT IS CREATED WITH THE VM AND ASSOCIATED WITH THE NIC BY DEFAULT
$nicName = az vm show -n "brand-hub-vm-01" -g $rg --query 'networkProfile.networkInterfaces[0].id' -o tsv | cut -d'/' -f 9
$nsgName = az network nic show --name $nicName --resource-group $rg --query 'networkSecurityGroup.id' -o tsv | cut -d'/' -f 9
$nic = Get-AzNetworkInterface -ResourceGroupName $rg -Name $nicName
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $rg -Name $nsgName
$nic.NetworkSecurityGroup = $null
$nic | Set-AzNetworkInterface
Remove-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $rg -Force

## PRINT OUT VM PUBLIC IP FOR STUDENTS TO USE
$pip = az vm list-ip-addresses --resource-group brandrg --name brand-hub-vm-01 --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv
echo "==============================================================="
echo "The public IP address of the VM is: $pip"
echo "==============================================================="

##############################
######## END - SCRIPT ########
##############################
