# Import the AzureRM modules
Import-Module Az.Accounts
Import-Module Az.Compute

# Specify the resource group and VMSS name
$resourceGroupName = 'acdnd-c4-project'
$vmssName = 'udacity-vmss'
$automationAccount = "azure-performance-AA"

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process | Out-Null
$AzureContext = (Connect-AzAccount -Identity).context
# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
Write-Output "Using system-assigned managed identity"

# Get the VMSS object
$vmss = Get-AzVmss -ResourceGroupName $resourceGroupName -VMScaleSetName $vmssName -DefaultProfile $AzureContext

# Get the current capacity
$currentCapacity = $vmss.Sku.Capacity

# Specify the new capacity
$newCapacity = $currentCapacity + 2

Write-Output "Old capacity: $currentCapacity"
# Update the VMSS
Update-AzVmss -ResourceGroupName $resourceGroupName -Name $vmssName -SkuCapacity $newCapacity -VirtualMachineScaleSet $vmss -DefaultProfile $AzureContext
Write-Output "Updating the capacity"
# Get the updated VMSS object
$updatedVmss = Get-AzVmss -ResourceGroupName $resourceGroupName -VMScaleSetName $vmssName -DefaultProfile $AzureContext

# Get the updated instance count and capacity
$updatedCapacity = $updatedVmss.Capacity

# Print the old and new capacity, instance count
Write-Output "Old capacity: $currentCapacity"
Write-Output "New capacity: $updatedCapacity"
