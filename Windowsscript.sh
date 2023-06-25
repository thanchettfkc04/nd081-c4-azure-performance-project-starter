#!/bin/bash

# Variables
resourceGroup="acdnd-c4-project"
location="southeastasia"
osType="UbuntuLTS"
vmssName="udacity-vmss"
adminName="udacityadmin"
storageAccount="udacitydiag100495"
bePoolName="udacity-vmss-bepool"
lbName="udacity-vmss-lb"
lbRule="udacity-vmss-lb-network-rule"
nsgName="udacity-vmss-nsg"
vnetName="udacity-vmss-vnet"
subnetName="udacity-vmss-vnet-subnet"
probeName="tcpProbe"
vmSize="Standard_B1s"
storageType="Standard_LRS"

# Create resource group. 
# This command will not work for the Cloud Lab users. 
# Cloud Lab users can comment this command and 
# use the existing Resource group name, such as, resourceGroup="cloud-demo-153430" 
echo "STEP 0 - Creating resource group acdnd-c4-project..."

az group create --name acdnd-c4-project --location southeastasia --verbose

echo "Resource group created: acdnd-c4-project"

# Create Storage account
echo "STEP 1 - Creating storage account udacitydiag100495"

az storage account create --name udacitydiag100495 --resource-group acdnd-c4-project --location southeastasia --sku Standard_LRS

echo "Storage account created: udacitydiag100495"

# Create Network Security Group
echo "STEP 2 - Creating network security group udacity-vmss-nsg"

az network nsg create --resource-group acdnd-c4-project --name udacity-vmss-nsg --verbose

echo "Network security group created: udacity-vmss-nsg"

# Create VM Scale Set
echo "STEP 3 - Creating VM scale set udacity-vmss"

az vmss create --resource-group acdnd-c4-project --name udacity-vmss --image UbuntuLTS --vm-sku Standard_B1s --nsg udacity-vmss-nsg --subnet udacity-vmss-vnet-subnet --vnet-name udacity-vmss-vnet --backend-pool-name udacity-vmss-bepool --storage-sku Standard_LRS --load-balancer udacity-vmss-lb --custom-data cloud-init.txt --upgrade-policy-mode automatic --admin-username udacityadmin --generate-ssh-keys --verbose 

echo "VM scale set created: udacity-vmss"

# Associate NSG with VMSS subnet
echo "STEP 4 - Associating NSG: udacity-vmss-nsg with subnet: udacity-vmss-vnet-subnet"

az network vnet subnet update --resource-group acdnd-c4-project --name udacity-vmss-vnet-subnet --vnet-name udacity-vmss-vnet --network-security-group udacity-vmss-nsg --verbose

echo "NSG: udacity-vmss-nsg associated with subnet: udacity-vmss-vnet-subnet"

# Create Health Probe
echo "STEP 5 - Creating health probe tcpProbe"

az network lb probe create --resource-group acdnd-c4-project --lb-name udacity-vmss-lb --name tcpProbe --protocol tcp --port 80 --interval 5 --threshold 2 --verbose

echo "Health probe created: tcpProbe"

# Create Network Load Balancer Rule
echo "STEP 6 - Creating network load balancer rule udacity-vmss-lb-network-rule"

az network lb rule create --resource-group acdnd-c4-project --name udacity-vmss-lb-network-rule --lb-name udacity-vmss-lb --probe-name tcpProbe --backend-pool-name udacity-vmss-bepool --backend-port 80 --frontend-ip-name loadBalancerFrontEnd --frontend-port 80 --protocol tcp --verbose

echo "Network load balancer rule created: udacity-vmss-lb-network-rule"

# Add port 80 to inbound rule NSG
echo "STEP 7 - Adding port 80 to NSG udacity-vmss-nsg"

az network nsg rule create --resource-group acdnd-c4-project --nsg-name udacity-vmss-nsg --name Port_80 --destination-port-ranges 80 --direction Inbound --priority 100 --verbose

echo "Port 80 added to NSG: udacity-vmss-nsg"

# Add port 22 to inbound rule NSG
echo "STEP 8 - Adding port 22 to NSG udacity-vmss-nsg"

az network nsg rule create --resource-group acdnd-c4-project --nsg-name udacity-vmss-nsg --name Port_22 --destination-port-ranges 22 --direction Inbound --priority 110 --verbose

echo "Port 22 added to NSG: udacity-vmss-nsg"

echo "VMSS script completed!"
