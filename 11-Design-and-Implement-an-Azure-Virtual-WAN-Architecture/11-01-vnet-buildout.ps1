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

# Create Virtual Networks and subnets

az network vnet create --name spoke-1-vnet --resource-group $rg --location $location --address-prefixes 10.3.0.0/16 --subnet-name spoke-1-subnet-a --subnet-prefix 10.3.1.0/24

az network vnet create --name spoke-2-vnet --resource-group $rg --location $location --address-prefixes 10.4.0.0/16 --subnet-name spoke-2-subnet-a --subnet-prefix 10.4.1.0/24


# Create two Linux machines. One in each network

az vm create --resource-group $rg --name spoke-1-vm --image Ubuntu2204 --admin-username "azureuser" --admin-password "Brandadmin@123" --public-ip-address myPublicIP-nva --public-ip-sku Standard --vnet-name spoke-1-vnet --subnet spoke-1-subnet-a --size Standard_B1s

az vm create --resource-group $rg --name spoke-2-vm --image Ubuntu2204 --admin-username "azureuser" --admin-password "Brandadmin@123" --public-ip-address myPublicIP-spoke-2-vm --public-ip-sku Standard --vnet-name spoke-2-vnet --subnet spoke-2-subnet-a --size Standard_B1s


# Add rules to default NIC NSGs to allow ICMP
az network nsg rule create --resource-group $rg --nsg-name spoke-1-vmNSG --name allowIcmp --priority 110 --destination-port-ranges 0-65535 --access Allow --protocol Icmp

az network nsg rule create --resource-group $rg --nsg-name spoke-2-vmNSG --name allowIcmp --priority 110 --destination-port-ranges 0-65535 --access Allow --protocol Icmp

