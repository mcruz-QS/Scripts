if ((Get-AzureRmContext).Account -eq $null){
    Login-AzureRmAccount
}else{
    "Currently Logged into: " + $(Get-AzureRmContext).Subscription.Name
}

$AZRMSubs = Get-AzureRmSubscription
$i = 0
foreach ($AZRMSub in $AZRMSubs){
    $count = $AZRMSubs.count - $i
    $context = $null
    $context = (Set-AzureRmContext $AZRMSub)
    write-verbose $("There are $count subscriptions we are on - " + $context.Subscription.Name) -Verbose
    $i ++;

    #Get-AzureRmContext
    $nsg = $null
    $nsg = Get-AzureRmNetworkSecurityGroup
    $nicInt = (Get-AzureRmNetworkInterface)
    $nicInt | ForEach-Object { $_ |
        Add-Member -MemberType NoteProperty -Name "NSG" -Value ($(($_.networksecuritygroup).id) -split "/")[-1] -Force -PassThru |
        Add-Member -MemberType NoteProperty -Name "SubscriptionName" -Value $($_.Subscription.Name) -Force -PassThru |
        Add-Member -MemberType NoteProperty -Name "PrivateIpAddress" -Value $($_.IpConfigurations.PrivateIpAddress) -Force -PassThru |
        Add-Member -MemberType NoteProperty -Name "PublicIpAddress" -Value $($_.IpConfigurations.PublicIpAddress) -Force -PassThru |
        Select-Object Name, subscriptionname, NSG, PrivateIpAddress, PublicIpAddress }
    <#
    $nsg | Select-Object Name, ResourceGroupName
        if ($($nsg.ResourceGroupName) -eq 'dcuergrel000' ){
        $nsg | Out-File C:\Temp\nsg2.txt
        "test"
    }

    $rmVNets = Get-AzureRmVirtualNetwork
    foreach ($rmVNet in $rmVNets){
        $rmVNet | Select-Object name, ResourceGroupName
        ($rmVNet).subnets   | Select-Object addressprefix, networksecuritygroup, name
    }
    #>
}