<#
.SYNOPSIS
Lists all resources (classic and ARM)  in the given subscriptions and outputs the results to a csv file

.DESCRIPTION
Lists all resources (classic and ARM)  in the given subscriptions and outputs the results to a csv file
Requires powershell 5 or higher
You must authenticate to Azure for both classic and ARM in order to run this script
e.g.
Add-AzureAccount
Login-AzureRmAccount

.PARAMETER Subscriptions
List of subscriptions e.g. @('test', 'prod)
#>
function Get-AZResorcesAll {
[CmdletBinding()]
param
(
	[Parameter(Mandatory = $true)][array]$Subscriptions,
	$fileName =  '_AllResources.csv',
    [pscredential]$cred
)
begin{
     Class AzureResource
    {
	    [string]$Subscription
	    [string]$ResourceType
	    [string]$ResourceId
	    [string]$ResourceGroup
	    [string]$Location
	    [string]$Name
	    [string]$ServiceName
	    [string]$VNet
	    [string]$Subnet
	    [string]$Size
	    [string]$Status
    }
}
process{
    # $listOfSubscriptions = $Subscriptions -join '-'
    $file = $fileName
    Write-Output "Outputing data to file $file"
    $allResources = @()

    # Custom class to store the data (needs powershell 5)
   

    foreach ($subscription in $Subscriptions) {
	    # Select the subscription in both arm and classic modes
	    try {
            Write-Verbose $subscription
            # Get-AzureRmSubscription -SubscriptionName $Subscription | Add-AzureAccount -Credential $cred -Tenant $_.TenantId
            Select-AzureSubscription -SubscriptionName $Subscription -Current -ErrorAction Stop -Account $cred| Out-Null
            
	    }catch{
		    write-verbose "Could not connect to $subscription with AZ Classic"
	    }
        try {
                Write-Verbose $subscription
			    Select-AzureRmSubscription -SubscriptionName $Subscription	-ErrorAction stop | Out-Null
		    }catch{
                write-verbose "Could not connect to $subscription with AZ Classic"
		    }

	    Write-Verbose "Processing data for subscription $Subscription"
	    $vms = New-Object System.Collections.ArrayList($null)
        Get-AzureVM | foreach {$vms.Add($_)} | Out-Null
	    $armVMs = New-Object System.Collections.ArrayList($null)
        Get-AzureRmVM | foreach {$armVMs.Add($_)} | Out-Null
	    $resources = New-Object System.Collections.ArrayList($null)
        Get-AzureRmResource | foreach {$resources.Add($_)} | Out-Null
	    ($resources).count
	    $i = ($resources).count
        
	    foreach($resource in $resources)
	    {
		    $i | foreach {
			    if (($_ % 10) -eq 1){$_}
		    }; $i --;

		    if($resource.ResourceType -eq 'Microsoft.ClassicCompute/virtualMachines')
		    {
			    # Classic VM
			    Write-Verbose "Classic VMs"
                    #if ($vms.Count -eq 0){write-warning "No RM VMs to count"}
                    $vm = $vms | Where-Object { $_.Name -eq $(($resource.ResourceId -split "/")[-1])}
                    if (!($vm)){
                       "$(($resource.ResourceId -split "/")[-1]) no VM?"
                    }else{
                        $vm.name
                    }
                    $azureResource = New-Object AzureResource				
                    $azureResource.VNet = $vm.VirtualNetworkName
				    # $azureResource.Subnet = Get-AzureSubnet -VM $vm
				    $azureResource.Size = $vm.InstanceSize
				    $azureResource.Status = $vm.InstanceStatus
				    $azureResource.ServiceName = $vm.ServiceName
		            $azureResource.Subscription = $Subscription
		            $azureResource.ResourceType = $resource.ResourceType
		            $azureResource.Location = $resource.Location
		            $azureResource.ResourceId = $resource.ResourceId
		            $azureResource.ResourceGroup = $vm.ResourceGroupName
		            $azureResource.Name = $vm.Name
                
                    $allResources += $azureResource
                 $vms.Remove(($vms | Where-Object { $_.Name -eq $(($resource.ResourceId -split "/")[-1])}))    
                
		    }
            
		    if($resource.ResourceType -eq 'Microsoft.Compute/virtualMachines')
		    {
			    # ARM VM
			    Write-Verbose "Arm VMs"
			        if ($armVMs.Count -eq 0){write-warning "No RM VMs to count"}
				    $armVM = $armVMs | Where-Object { $_.Name -eq $(($resource.ResourceId -split "/")[-1])}
                    write-verbose $armVM.name
           		    $azureResource = New-Object AzureResource				
                    $azureResource.Size = $armVM.HardwareProfile.VMSize
				    $vmstatus = Get-AzurermVM -Name $armVM.Name -ResourceGroupName $armVM.ResourceGroupName -Status
				    $azureResource.Status = (get-culture).TextInfo.ToTitleCase(($vmstatus.statuses)[1].code.split("/")[1])
				    $nicName = ($armvm.NetworkProfile[0].NetworkInterfaces.id -split '/')[-1]
				    $nic = Get-AzureRmNetworkInterface -Name $nicName -ResourceGroupName $armvm.ResourceGroupName
				    $IpConfig = ConvertFrom-Json -InputObject $nic.IpConfigurationsText
				    # $subnet = $IpConfig.Name
				    $azureResource.VNet = $nicName
				    $azureResource.Subnet = $IpConfig.ProvisioningState
                    $azureResource.ServiceName = $armVM.ServiceName
		            $azureResource.Subscription = $Subscription
		            $azureResource.ResourceType = $resource.ResourceType
		            $azureResource.Location = $resource.Location
		            $azureResource.ResourceId = $resource.ResourceId
		            $azureResource.ResourceGroup = $armVM.ResourceGroupName
		            $azureResource.Name = $armVM.Name
                
                    $allResources += $azureResource
                 $armVMS.Remove(($armVMs | Where-Object { $_.Name -eq $(($azureResource.ResourceId -split "/")[-1])}))       
			    
                
		    }
            
            else{
                $azureResource = New-Object AzureResource
		        $azureResource.Subscription = $Subscription
		        $azureResource.ResourceType = $resource.ResourceType
		        $azureResource.Location = $resource.Location
		        $azureResource.ResourceId = $resource.ResourceId
		        $azureResource.ResourceGroup = $resource.ResourceGroupName
		        $azureResource.Name = $resource.Name
            
                $allResources += $azureResource 
            }
            
	    }
    }
}
end{
    
    	# output the data to the csv file
	$allResources = $allResources | Sort-Object Subscription, ResourceType
	$allResources | Export-Csv -Path $file -Force -notypeinformation

}

}