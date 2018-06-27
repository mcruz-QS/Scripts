<#
Adding SqlFirewall to
Create an Azure SQL Firewall rule on the Azure SQL Server
itself allowing access to the Austin IP Address(es) and your own if working remotely.
#>
$sqlServers = ($Global:runningConfig.Azure.Settings) | Select-Object sqlserver*server
if ($sqlServers.count -gt 0){
    $sqlFirewallRules = Get-Content C:\Users\m.cruz\Documents\git\EnvironmentSetup\QS\inputs\sqlFirewallRule.json | ConvertFrom-Json
    foreach ($sqlServer in $sqlServers){
        $sqlFirewallRules | ForEach-Object {$_.servername = $sqlServer}
        $sqlFirewallRules | ForEach-Object {$_.ResourceGroupName = $($Global:runningConfig.Azure.Settings.ResourceGroupName)}

        New-AzureRmSqlServerFirewallRule -ResourceGroupName "ResourceGroup01" -ServerName "Server01" -FirewallRuleName "Rule01" -StartIpAddress "192.168.0.198" -EndIpAddress "192.168.0.199"
    }
}