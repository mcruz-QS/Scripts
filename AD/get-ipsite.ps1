#---newely added function to translate ip to site with nslookup----

function Get-ipSite
{
    param([string]$ip
    )
    #Great idea from http://superuser.com/questions/758372/query-site-for-given-ip-from-ad-sites-and-services/758398
    $site = nltest /DSADDRESSTOSITE:$ip /dsgetsite 2>$null
    if ($LASTEXITCODE -eq 0) {
        $split = $site[3] -split "\s+"
        # validate result is for an IPv4 address before continuing
        if ($split[1] -match [regex]"^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$") {
            "" | select @{l="ADSite";e={$split[2]}}, @{l="ADSubnet";e={$split[3]}}
        }
    }

}

$d = [DateTime]::Today.AddDays(-90)
$default_log = $env:userprofile + '\Documents\Computer_Site_Report.csv'

Foreach($domain in (get-adforest).domains){
    Get-ADComputer  -Filter {(isCriticalSystemObject -eq $False)} -Properties UserAccountControl,`
        PwdLastSet,WhenChanged,SamAccountName,LastLogonTimeStamp,Enabled,admincount,IPv4Address,`
        operatingsystem,operatingsystemversion,serviceprincipalname  -server $domain |
        select @{name='Domain';expression={$domain}}, `
        SamAccountName,operatingsystem,operatingsystemversion,UserAccountControl,Enabled, `
        admincount,IPv4Address, `
        @{Name="Site";Expression={if($_.IPv4Address){(get-ipsite $_.IPv4Address).ADSite}}}, `  #<----Site
        @{Name="Supnet";Expression={if($_.IPv4Address){(get-ipsite $_.IPv4Address).ADSubnet}}}, ` #<----Subnet
        @{Name="Stale";Expression={if((($_.pwdLastSet -lt $d.ToFileTimeUTC()) -and ($_.pwdLastSet -ne 0)`
        -and ($_.LastLogonTimeStamp -lt $d.ToFileTimeUTC()) -and ($_.LastLogonTimeStamp -ne 0)`
        -and ($_.admincount -ne 1) -and ($_.IPv4Address -eq $null)) -and `
        (!($_.serviceprincipalname -like "*MSClusterVirtualServer*"))){$True}else{$False}}}, `
        @{Name="ParentOU";Expression={$_.distinguishedname.Substring($_.samaccountname.Length + 3)}} `
        | export-csv $default_log -append -NoTypeInformation
}