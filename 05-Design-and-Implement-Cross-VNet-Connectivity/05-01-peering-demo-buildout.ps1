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

az network vnet create --name brand-hub-vnet --resource-group $rg --location $location --address-prefixes 10.0.0.0/16 --subnet-name nva-subnet --subnet-prefix 10.0.1.0/24

az network vnet create --name brand-spoke1-vnet --resource-group $rg --location $location --address-prefixes 10.1.0.0/16 --subnet-name spoke-1-subnet-a --subnet-prefix 10.1.1.0/24

az network vnet create --name brand-spoke2-vnet --resource-group $rg --location $location --address-prefixes 10.2.0.0/16 --subnet-name spoke-2-subnet-a --subnet-prefix 10.2.1.0/24

# Create three Linux machines. One in each network

az vm create --resource-group $rg --name spoke-1-vm --image Ubuntu2204 --generate-ssh-keys --public-ip-address myPublicIP-spoke-1-vm --public-ip-sku Standard --vnet-name brand-spoke1-vnet --subnet spoke-1-subnet-a --size Standard_B1s --no-wait

az vm create --resource-group $rg --name spoke-2-vm --image Ubuntu2204 --generate-ssh-keys --public-ip-address myPublicIP-spoke-2-vm --public-ip-sku Standard --vnet-name brand-spoke2-vnet --subnet spoke-2-subnet-a --size Standard_B1s --no-wait

az vm create --resource-group $rg --name hub-nva-vm --image Ubuntu2204 --generate-ssh-keys --public-ip-address myPublicIP-nva --public-ip-sku Standard --vnet-name brand-hub-vnet --subnet nva-subnet --size Standard_B1s

# Update the NVA VM to enable IP forwarding. This needs to be enabled on both the VM NIC and within the OS
# via extension.

az network nic update --name hub-nva-vmVMNic --resource-group $rg --ip-forwarding true

#az vm extension set --resource-group $rg --vm-name hub-nva-vm --name customScript --publisher Microsoft.Azure.Extensions --settings '{\"commandToExecute\":\"sudo sysctl -w net.ipv4.ip_forward=1\"}'
## PRINT OUT VM PUBLIC IP FOR STUDENTS TO USE
$pip = az vm list-ip-addresses --resource-group $rg --name hub-nva-vm --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" --output tsv
echo "==============================================================="
echo "The public IP address of the VM is: $pip"
echo "==============================================================="
##############################
######## END - SCRIPT ########
##############################
