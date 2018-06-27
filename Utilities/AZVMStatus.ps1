$vmlist = @()
$RGs = Get-AzureRmResourceGroup
foreach ($rg in $RGs){
    Write-Verbose $("Testing " + $rg.ResourceGroupName) -Verbose
    $vms = Get-AzureRmVM -ResourceGroupName $rg.ResourceGroupName
    foreach ($vm in $vms){
        $vmdetail = Get-AzureRmVM -ResourceGroupName $rg.ResourceGroupName -name $vm.Name -status
        $vmstatus = $null
        foreach($vmstatus in $vmdetail.Statuses){
        if ($vmstatus.code.compareto("ProvisioningState/succeeded")){
            $vmstatusdetail = $vmstatus.Displaystatus
        }
    }
        $vmlist += [PSCustomObject]@{
            Name = $vm.Name;
            Status = $vmstatusdetail
            ResourceGroup = $rg.ResourceGroupName

        }
        $vmlist
    }
}