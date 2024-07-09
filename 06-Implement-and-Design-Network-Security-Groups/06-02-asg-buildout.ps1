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


## CLOUD INIT FOR USERDATA SETUP OF VM
curl https://raw.githubusercontent.com/mrcloudchase/Azure/master/cloud-init.txt -o cloud-init.txt

## SETUP MAIN HUB VNET
# Create main hub vnet
az network vnet create --name brand-hub-vnet --resource-group $rg --location $location --address-prefixes 10.60.0.0/16 --subnet-name hub-subnet-01 --subnet-prefix 10.60.0.0/24

# Create nsg-01
az network nsg create -g $rg -n hub-nsg-01

# Associate nsg-01 with subnet-01 in main hub vnet
az network vnet subnet update --resource-group $rg --vnet-name brand-hub-vnet --name hub-subnet-01 --network-security-group hub-nsg-01

# Create nsg-01 rules allow SSH|HTTP from Anywhere
az network nsg rule create --resource-group $rg --nsg-name hub-nsg-01 --name allowHttp --priority 110 --destination-port-ranges 80 --source-address-prefixes '*' --access Allow --protocol Tcp
az network nsg rule create --resource-group $rg --nsg-name hub-nsg-01 --name denySsh --priority 120 --destination-port-ranges 22 --source-address-prefixes '*' --access Deny --protocol Tcp

# Create vm-1 in main hub vnet subnet-01
az vm create --resource-group $rg --location $location --name brand-hub-vm-01 --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address brand-hub-pip-01 --public-ip-sku Standard --vnet-name brand-hub-vnet --subnet hub-subnet-01 --nsg hub-nsg-01 --size Standard_B1s --no-wait

# Create vm-2 in main hub vnet subnet-01
az vm create --resource-group $rg --location $location --name brand-hub-vm-02 --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address brand-hub-pip-02 --public-ip-sku Standard --vnet-name brand-hub-vnet --subnet hub-subnet-01 --nsg hub-nsg-01 --size Standard_B1s --no-wait


## SETUP SPOKE 1 VNET
# Create spoke 1 vnet
az network vnet create --name brand-spoke1-vnet --resource-group $rg --location $location  --address-prefixes 10.120.0.0/16 --subnet-name spoke1-subnet-01 --subnet-prefix 10.120.0.0/24

# Create nsg-01
az network nsg create -g $rg -n spoke1-nsg-01

# Associate nsg-01 with subnet-01 in spoke 1 hub vnet
az network vnet subnet update --resource-group $rg --vnet-name brand-spoke1-vnet --name spoke1-subnet-01 --network-security-group spoke1-nsg-01

# Create nsg-01 rules allow SSH|HTTP from Anywhere
az network nsg rule create --resource-group $rg --nsg-name spoke1-nsg-01 --name allowHttp --priority 110 --destination-port-ranges 80 --source-address-prefixes '*' --access Allow --protocol Tcp
az network nsg rule create --resource-group $rg --nsg-name spoke1-nsg-01 --name denySsh --priority 120 --destination-port-ranges 22 --source-address-prefixes '*' --access Deny --protocol Tcp

# Create vm-1 in spoke 1 vnet subnet-01
az vm create --resource-group $rg --location $location --name brand-spoke1-vm-01 --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address brand-spoke1-pip-01 --public-ip-sku Standard --vnet-name brand-spoke1-vnet --subnet spoke1-subnet-01 --nsg spoke1-nsg-01 --size Standard_B1s --no-wait

# Create vm-2 in spoke 1 vnet subnet-01
az vm create --resource-group $rg --location $location --name brand-spoke1-vm-02 --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address brand-spoke1-pip-02 --public-ip-sku Standard --vnet-name brand-spoke1-vnet --subnet spoke1-subnet-01 --nsg spoke1-nsg-01 --size Standard_B1s --no-wait


## SETUP SPOKE 2 VNET
# Create spoke 2 vnet
az network vnet create --name brand-spoke2-vnet --resource-group $rg --location $location  --address-prefixes 172.32.0.0/16 --subnet-name spoke2-subnet-01 --subnet-prefix 172.32.0.0/24

# Create nsg-01
az network nsg create -g $rg -n spoke2-nsg-01

# Associate nsg-01 with subnet-01 in spoke 2 hub vnet
az network vnet subnet update --resource-group $rg --vnet-name brand-spoke2-vnet --name spoke2-subnet-01 --network-security-group spoke2-nsg-01

# Create nsg-01 rules allow SSH|HTTP from Anywhere
az network nsg rule create --resource-group $rg --nsg-name spoke2-nsg-01 --name allowHttp --priority 110 --destination-port-ranges 80 --source-address-prefixes '*' --access Allow --protocol Tcp
az network nsg rule create --resource-group $rg --nsg-name spoke2-nsg-01 --name denySsh --priority 120 --destination-port-ranges 22 --source-address-prefixes '*' --access Deny --protocol Tcp

# Create vm-1 in spoke 2 vnet subnet-01
az vm create --resource-group $rg --location $location --name brand-spoke2-vm-01 --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address brand-spoke2-pip-01 --public-ip-sku Standard --vnet-name brand-spoke2-vnet --subnet spoke2-subnet-01 --nsg spoke2-nsg-01 --size Standard_B1s --no-wait

# Create vm-2 in spoke 2 vnet subnet-01
az vm create --resource-group $rg --location $location --name brand-spoke2-vm-02 --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address brand-spoke2-pip-02 --public-ip-sku Standard --vnet-name brand-spoke2-vnet --subnet spoke2-subnet-01 --nsg spoke2-nsg-01 --size Standard_B1s --no-wait


##############################
######## END - SCRIPT ########
##############################
