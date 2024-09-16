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
az network vnet create --name br-hub-vnet --resource-group $rg --location $location --address-prefixes 10.60.0.0/16 --subnet-name hub-subnet-01 --subnet-prefix 10.60.0.0/24

# Create nsg-01
az network nsg create -g $rg -n br-hub-nsg-01

# Associate nsg-01 with subnet-01 in main hub vnet
az network vnet subnet update --resource-group $rg --vnet-name br-hub-vnet --name hub-subnet-01 --network-security-group br-hub-nsg-01

# Create nsg-01 rules allow SSH|HTTP from Anywhere
az network nsg rule create --resource-group $rg --nsg-name br-hub-nsg-01 --name allowHttp --priority 110 --destination-port-ranges 80 --source-address-prefixes '*' --access Allow --protocol Tcp
az network nsg rule create --resource-group $rg --nsg-name br-hub-nsg-01 --name allowSsh --priority 120 --destination-port-ranges 22 --source-address-prefixes '*' --access Allow --protocol Tcp

# Create vm-1 in main hub vnet subnet-01
az vm create --resource-group $rg --location $location --name br-hub-vm-01 --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address br-hub-pip-01 --public-ip-sku Standard --vnet-name br-hub-vnet --subnet hub-subnet-01 --nsg br-hub-nsg-01 --size Standard_B1s --no-wait

# Create vm-2 in main hub vnet subnet-01
az vm create --resource-group $rg --location $location --name br-hub-vm-02 --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address br-hub-pip-02 --public-ip-sku Standard --vnet-name br-hub-vnet --subnet hub-subnet-01 --nsg br-hub-nsg-01 --size Standard_B1s --no-wait


## SETUP SPOKE 1 VNET
# Create spoke 1 vnet
az network vnet create --name br-spoke1-vnet --resource-group $rg --location $location  --address-prefixes 10.120.0.0/16 --subnet-name spoke1-subnet-01 --subnet-prefix 10.120.0.0/24

# Create nsg-01
az network nsg create -g $rg -n br-spoke1-nsg-01

# Associate nsg-01 with subnet-01 in spoke 1 hub vnet
az network vnet subnet update --resource-group $rg --vnet-name br-spoke1-vnet --name spoke1-subnet-01 --network-security-group br-spoke1-nsg-01

# Create nsg-01 rules allow SSH|HTTP from Anywhere
az network nsg rule create --resource-group $rg --nsg-name br-spoke1-nsg-01 --name allowHttp --priority 110 --destination-port-ranges 80 --source-address-prefixes '*' --access Allow --protocol Tcp
az network nsg rule create --resource-group $rg --nsg-name br-spoke1-nsg-01 --name allowSsh --priority 120 --destination-port-ranges 22 --source-address-prefixes '*' --access Allow --protocol Tcp

# Create vm-1 in spoke 1 vnet subnet-01
az vm create --resource-group $rg --location $location --name br-spoke1-vm-01 --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address br-spoke1-pip-01 --public-ip-sku Standard --vnet-name br-spoke1-vnet --subnet spoke1-subnet-01 --nsg br-spoke1-nsg-01 --size Standard_B1s --no-wait

# Create vm-2 in spoke 1 vnet subnet-01
az vm create --resource-group $rg --location $location --name br-spoke1-vm-02 --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address br-spoke1-pip-02 --public-ip-sku Standard --vnet-name br-spoke1-vnet --subnet spoke1-subnet-01 --nsg br-spoke1-nsg-01 --size Standard_B1s --no-wait


## SETUP SPOKE 2 VNET
# Create spoke 2 vnet
az network vnet create --name br-spoke2-vnet --resource-group $rg --location $location  --address-prefixes 172.32.0.0/16 --subnet-name spoke2-subnet-01 --subnet-prefix 172.32.0.0/24

# Create nsg-01
az network nsg create -g $rg -n br-spoke2-nsg-01

# Associate nsg-01 with subnet-01 in spoke 2 hub vnet
az network vnet subnet update --resource-group $rg --vnet-name br-spoke2-vnet --name spoke2-subnet-01 --network-security-group br-spoke2-nsg-01

# Create nsg-01 rules allow SSH|HTTP from Anywhere
az network nsg rule create --resource-group $rg --nsg-name br-spoke2-nsg-01 --name allowHttp --priority 110 --destination-port-ranges 80 --source-address-prefixes '*' --access Allow --protocol Tcp
az network nsg rule create --resource-group $rg --nsg-name br-spoke2-nsg-01 --name allowSsh --priority 120 --destination-port-ranges 22 --source-address-prefixes '*' --access Allow --protocol Tcp

# Create vm-1 in spoke 2 vnet subnet-01
az vm create --resource-group $rg --location $location --name br-spoke2-vm-01 --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address br-spoke2-pip-01 --public-ip-sku Standard --vnet-name br-spoke2-vnet --subnet spoke2-subnet-01 --nsg br-spoke2-nsg-01 --size Standard_B1s --no-wait

# Create vm-2 in spoke 2 vnet subnet-01
az vm create --resource-group $rg --location $location --name br-spoke2-vm-02 --image Ubuntu2204 --admin-username azureuser --generate-ssh-keys --user-data ./cloud-init.txt --public-ip-address br-spoke2-pip-02 --public-ip-sku Standard --vnet-name br-spoke2-vnet --subnet spoke2-subnet-01 --nsg br-spoke2-nsg-01 --size Standard_B1s --no-wait


## CREATE PEERING CONNECTIONS
# Create peering connection between hub-vnet and spoke1-vnet
az network vnet peering create --resource-group $rg --name hub-to-spoke1-peering --vnet-name br-hub-vnet --remote-vnet br-spoke1-vnet --allow-vnet-access --allow-forwarded-traffic
az network vnet peering create --resource-group $rg --name spoke1-to-hub-peering --vnet-name br-spoke1-vnet --remote-vnet br-hub-vnet --allow-vnet-access --allow-forwarded-traffic

## CREATE FIREWALL RESOURCES

# Install extensions without prompt
$global:setConfig = az config set extension.use_dymanic_install=yes_without_prompt # may work if not already installed - otherwise perform as pre-step before running script
$global:setConfig

# Create AzureFirewallSubnet for spoke2-vnet
az network vnet subnet create --resource-group $rg --vnet-name br-spoke2-vnet --name AzureFirewallSubnet --address-prefix 172.32.1.0/26

# Create Firewall PIP for br-spoke2-firewall-01
az network public-ip create --resource-group $rg --name br-spoke2-firewall-pip-01 --location $location --allocation-method Static --sku Standard

# Create the management configuration and IP required for the basic SKU firewall
az network vnet subnet create --name AzureFirewallManagementSubnet --resource-group $rg --vnet-name br-spoke2-vnet --address-prefixes 172.32.2.0/26

az network public-ip create --name br-fw-management-ip --resource-group $rg --allocation-method Static --sku Standard

# Create br-spoke2-firewall-01 with Basic SKU for compatibility with the Azure Sandbox
az network firewall create --resource-group $rg --name br-spoke2-firewall-01 --location $location --sku AZFW_VNet --tier Basic --vnet-name br-spoke2-vnet --conf-name fw-ip-config --public-ip br-spoke2-firewall-pip-01 --m-conf-name management-ip-config --m-public-ip br-fw-management-ip
# Note: If using your own AZure account you can use: 
# the command `az network firewall create --resource-group $rg --name br-spoke2-firewall-01 --location $location` to create a Premium Firewall


# Below commands commented out as they are redundant for basic SKU firewall
# # Create Firewall IP Config for br-spoke2-firewall-01
# az network firewall ip-config create --resource-group $rg --firewall-name br-spoke2-firewall-01 --name br-spoke2-firewall-ip-config --public-ip-address br-spoke2-firewall-pip-01 --vnet-name br-spoke2-vnet

# # Update the firewall to associate the IP config
# az network firewall update --resource-group $rg --name br-spoke2-firewall-01

# Get firewall private IP address and set to variable for reuse
$hubfwprivip = az network firewall show --resource-group $rg --name br-spoke2-firewall-01 --query "ipConfigurations[0].privateIPAddress" --output tsv

# Create main Route Table that will push traffic from br-spoke2-vnet associated subnets to br-spoke2-firewall-01
az network route-table create --resource-group $rg --name br-spoke2-fw-route-table --location $location --disable-bgp-route-propagation true

# Create the route that will push traffic from br-spoke2-vnet associated subnets to br-spoke2-firewall-01
az network route-table route create --resource-group $rg --route-table-name br-spoke2-fw-route-table --name br-spoke2-fw-route --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address $hubfwprivip

# Associate the route table with the br-spoke2-vnet spoke2-subnet-01
az network vnet subnet update --resource-group $rg --vnet-name br-spoke2-vnet --name spoke2-subnet-01 --route-table br-spoke2-fw-route-table --address-prefixes 172.32.0.0/24

##############################
######## END - SCRIPT ########
##############################
