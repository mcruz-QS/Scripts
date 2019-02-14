# Get the connection "AzureRunAsConnection"
$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
$uri = Get-AutomationVariable -Name 'InfluxDB'
$db = Get-AutomationVariable -Name 'InfluxDB_powerstate'
# Logging in to Azure...
$connectionResult = Connect-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId -ApplicationId $servicePrincipalConnection.ApplicationId -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
# $connectionResult | get-member
# $connectionResult
Set-AzureRmContext -Subscription  'LASO Development'
# Get-AzureRmContext

$RMVMs = get-azurermvm -status
($RMVMs).count
$results = $RMVMs | select-object Name, ResourceGroupName, PowerState
$body = foreach ($result in $results ){
    if ($result.PowerState -eq 'VM deallocated'){
        $result.PowerState = 0
    }elseif ($result.PowerState -eq 'VM running'){
        $result.PowerState = 1
    }
    ("hosts,host=" + $result.name +",rgname=" + $result.ResourceGroupName +" PowerState=" + $result.PowerState +"`n" )
}
$body
(Invoke-WebRequest -Uri "$uri/write?db=$DB" -Method Post -Body ($body) -UseBasicParsing).statuscode
