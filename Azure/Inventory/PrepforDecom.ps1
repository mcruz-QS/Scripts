<#
    Resource Group Name needed
    Subscription Name needed
#>
QSconnectAZRM -Subscription 'LASO Development'
$RG = Get-AzureRmResourceGroup -Name dcuergtrn000 
$VMs = Get-AzureRmVM -ResourceGroupName $rg.ResourceGroupName
((Get-AzureRmPublicIpAddress -ResourceGroupName $rg.ResourceGroupName).DnsSettings).DomainNameLabel
foreach ($vm in $VMs){ Stop-AzureRmVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force -Confirm:$false}

$resource = Get-AzureRmResource -ResourceGroupName $rg.ResourceGroupName
$databases = $resource | where resourcetype -match "databases" 


$DBServers = $resource | where resourcetype -EQ "Microsoft.Sql/servers"
$DBServers | foreach {
    $DBs = Get-AzureRmSqlDatabase -ServerName $_.Name -ResourceGroupName $RG.ResourceGroupName | where databasename -ne "master"
    foreach ($DB in $DBS){
        Set-AzureRmSqlDatabase -DatabaseName $DB.DatabaseName -ServerName $DB.ServerName -ResourceGroupName $DB.ResourceGroupName `
            -Tags @{"Decom"="True"} -Edition Basic -Verbose 
    }
    # $DBs | select tags, Databasename, servername, resourcegroupname, Edition

}

$resource | foreach {
    Set-AzureRmResource -ResourceGroupName $rg.ResourceGroupName -Tag @{
        "Decom"="True";
        "Envrionment"="Training"
    } -ResourceName $_.Name -ResourceType $_.ResourceType -Force -Confirm:$False -AsJob
}

#region management

$RG = Get-AzureRmResourceGroup -Name dcuergtrnmanagement 
Set-AzureRmResourceGroup -Name $RG.ResourceGroupName -Tag @{
        "Decom"="True";
        "Envrionment"="Training"
    }

$resource = Get-AzureRmResource -ResourceGroupName $rg.ResourceGroupName
$resource | foreach {
    Set-AzureRmResource -ResourceGroupName $rg.ResourceGroupName -Tag @{
        "Decom"="True";
        "Envrionment"="Training"
    } -ResourceName $_.Name -ResourceType $_.ResourceType -Force -Confirm:$False
}
#endregion

#region Octoposh Disable
$octoEnv = "Training"
$VMs
Set-OctopusConnectionInfo -Server $octo.UserName -ApiKey $octo.GetNetworkCredential().password

$offlineVMOcto = foreach ($vm in $VMs){
    (Get-OctopusEnvironment $octoEnv).machines | where {($_.status -eq "offline") -and ($_.name -match $vm.Name )}
}
# Set VM to Disabled in OctopusDeploy 

$offlineVMOcto | foreach {
    try{
            $disableVM = get-octopusmachine $_.name
            $disableVM.resource.isdisabled = $true
            Update-OctopusResource -resource $disableVM.Resource

            
        }catch{
            $Error[0]
        }
}
#endregion

#region Octoposh removal
((Get-OctopusEnvironment $octoEnv).machines) | Remove-OctopusResource

#endregion