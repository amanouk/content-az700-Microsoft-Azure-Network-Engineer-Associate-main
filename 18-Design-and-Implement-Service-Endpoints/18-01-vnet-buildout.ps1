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
az group create --name brandrg --location centralus

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

# Create storage account name with randomly generated characters

$storagename = -join ((48..57) + (97..122) | Get-Random -Count 12 | % { [char]$_ })

# Create storage account

az storage account create --name $storagename --resource-group $rg --location $location

# Create Virtual Network and subnets

az network vnet create --name hub-vnet --resource-group $rg --location $location --address-prefixes 10.0.0.0/16 --subnet-name hub-subnet-a --subnet-prefix 10.0.1.0/24

az network vnet subnet create --name hub-subnet-b --resource-group $rg --vnet-name hub-vnet --address-prefixes 10.0.2.0/24 

# Create a Virtual Machine

az vm create --resource-group $rg --name vm-1 --image Win2019Datacenter --admin-username "azureuser" --admin-password "Brandadmin@123" --public-ip-address myPublicIP-vm1 --public-ip-sku Standard --vnet-name hub-vnet --subnet hub-subnet-a --size Standard_B1s
