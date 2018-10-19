# $subscriptions
$resourceGroup = 'Preview'
$SQLDBs =  Get-AzureRmResource -ResourceGroupName $resourceGroup -ResourceType Microsoft.Sql/servers/databases | Where-Object ResourceID -NotMatch "master"

ForEach ($SQLDB in $SQLDBs){
    $resSQL = $null
    $resSQL = Get-AzureRmSqlDatabase -ServerName $($sqlDB.Name -split "/")[0] -DatabaseName $($sqlDB.Name -split "/")[1] -ResourceGroupName $SQLDB.ResourceGroupName
    if (($resSQL.SkuName -eq "Premium")-and(($resSQL.ResourceId -match "preview")-or($resSQL.ResourceId -match "training"))){
        $resSQL | Set-AzureRmSqlDatabase -Edition Standard -RequestedServiceObjectiveName s4 -AsJob
    }else{
        Write-verbose "SQL is not Premium" -Verbose
    }

    #
}
