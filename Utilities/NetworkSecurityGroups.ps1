<#
    need to find Nics that don't have NSG Rules Associated to them
    Need to update NSG Rules
    Need to apply NSG Rules to them

#>

$nics = Get-AzureRmNetworkInterface
$nics | ForEach-Object {
    Start-Job -ScriptBlock {
        Get-AzureRmEffectiveNetworkSecurityGroup -ResourceGroupName $args.ResourceGroupName -NetworkInterfaceName $args.name
    } -Name $_.Name -ArgumentList $_
}

$Good = @()
$Bad = @()
get-job | ForEach-Object {if (($_ | Receive-Job -keep).NetworkSecurityGroup){$Good += ($_.name)}else{$Bad += ($_.name)}}

foreach ($badNic in $bad){
    write-verbose "working on $badNic"
    try{
        $ErrorActionPreference = "Stop"
        $changeNic = $nics | Where-Object Name -eq $badNic
        $addNSG = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $resourcegroupName

        if (($addNSG.SecurityRules | Where-Object {($_.name -match "FrontEndRDP") -or ($_.name -match "default-allow-rdp")}).SourceAddressPrefix -ne "45.25.134.48/29"){
            Write-Verbose "updating NSG with Austin IP"
            (($addNSG.SecurityRules  | Where-Object {($_.name -match "FrontEndRDP") -or ($_.name -match "default-allow-rdp")}).SourceAddressPrefix).add("45.25.134.48/29")
            (($addNSG.SecurityRules  | Where-Object {($_.name -match "FrontEndRDP") -or ($_.name -match "default-allow-rdp")}).SourceAddressPrefix).remove("*") | out-null
            if (($addNSG.SecurityRules  | Where-Object {($_.name -match "FrontEndRDP") -or ($_.name -match "default-allow-rdp")}).SourceAddressPrefix -ne "45.25.134.48/29"){
                write-warning "$addNSG.name is not set"
            }
            $addNSG | Set-AzureRmNetworkSecurityGroup
        }
        if ($addNSG.count -gt 1){write-warning "Number of NSG morethan 1 in $changeNic.ResourceGroupName"; break}
        $changeNic.NetworkSecurityGroup = $addNSG
        $changeNic | Set-AzureRmNetworkInterface
    }catch{
        $Error[0].exception.message
    }
}


function set-azRDPSource {
param(
    $resourcegroupName
)
    $addNSG = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $resourcegroupName

if (($addNSG.SecurityRules | Where-Object {($_.name -match "FrontEndRDP") -or ($_.name -match "default-allow-rdp")}).SourceAddressPrefix -ne "45.25.134.48/29"){
    Write-Verbose "updating NSG with Austin IP"
    (($addNSG.SecurityRules  | Where-Object {($_.name -match "FrontEndRDP") -or ($_.name -match "default-allow-rdp")}).SourceAddressPrefix).add("45.25.134.48/29")
    (($addNSG.SecurityRules  | Where-Object {($_.name -match "FrontEndRDP") -or ($_.name -match "default-allow-rdp")}).SourceAddressPrefix).remove("*") | out-null
    if (($addNSG.SecurityRules  | Where-Object {($_.name -match "FrontEndRDP") -or ($_.name -match "default-allow-rdp")}).SourceAddressPrefix -ne "45.25.134.48/29"){
        write-warning "$addNSG.name is not set"
    }
    $addNSG | Set-AzureRmNetworkSecurityGroup
}
}