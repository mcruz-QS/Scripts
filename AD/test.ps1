Get-ADReplicationPartnerMetadata -Target * -Partition * |
Select-Object Server,Partition,Partner,ConsecutiveReplicationFailures,LastReplicationSuccess,LastRepicationResult |
Out-GridView

function Get-ADSIComputerSite
{
    [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]::GetComputerSite()
}

$siteLink = Get-ADObject -LDAPFilter '(objectClass=siteLink)' `
    -SearchBase (Get-ADRootDSE).ConfigurationNamingContext `
    -Property Name, Cost, Description, Sitelist

$siteList = Get-ADObject -LDAPFilter '(&(objectClass=siteLink)(siteList=*))' `
-SearchBase (Get-ADRootDSE).ConfigurationNamingContext `
-Property Name, Cost, Sitelist, Options