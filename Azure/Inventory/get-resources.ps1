<#
    List all resource groups in all subscriptions
    List all resources in each resource group

#>

Connect-QSAzure -Subscription 'LASO Core Production' | out-null
$subscriptions = $(Get-Content C:\Users\m.cruz\AppData\Local\qsazure\subscription.json | ConvertFrom-Json).nam
$results = foreach ($subscription in $subscriptions) {
    Connect-QSAzure -Subscription $subscription | out-null
    $rgs= Get-AzureRmResourceGroup
    write-verbose $rgs.count -Verbose
    $rg = $null
    foreach ($rg in $rgs){
        Write-Verbose $rg.resourcegroupname -Verbose 
        Get-AzureRmResource -ResourceGroupName $rg.ResourceGroupName
    }
}

$res2 = foreach ($result in $results){
    [PSCustomObject]@{
        Name = $result.Name
        ResourceGroupName = $result.resourceGroupName
        Type = $result.Type
        Location = $result.Location
        ID = $result.ID
        ParentResource = $result.ParentResource
        Kind = $($result.Kind -replace ","," ")
        skuName = $result.sku.Name
        skuTier = $result.Sku.Tier
        skuCapacity = $result.Sku.Capacity
        tag = if (($result.Tags.keys) -gt ""){$($result.Tags).keys + " - " + $($result.Tags).values}else{$null}
        planName = $result.Plan.name
        planProduct = $result.Plan.Product
        
    }
    
}

# Classic
$TenantID = $(Get-Content C:\Users\m.cruz\AppData\Local\qsazure\subscription.json | ConvertFrom-Json)[0].TenantId
Add-AzureAccount -Credential $azure -Tenant $TenantID
$subscriptions = Get-AzureSubscription
$results2 = foreach ($subscription in $subscriptions) {
    Connect-QSAzure -Subscription $subscription | out-null
    $rgs= Get-AzureRmResourceGroup
    write-verbose $rgs.count -Verbose
    $rg = $null
    foreach ($rg in $rgs){
        Write-Verbose $rg.resourcegroupname -Verbose 
        Get-AzureRmResource -ResourceGroupName $rg.ResourceGroupName -ResourceType microsoft.ClassicCompute
    }
}



Get-AzureSubscription