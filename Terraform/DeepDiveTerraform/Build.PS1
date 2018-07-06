<#
    Things to do:
    Create ServicePrincipal for AZ
    Add SP to KeyVault for Security and backup
         Should SP have rights to subscription or create multiple
         to access each resource - that may be over kill for initial set up

#>

$credential = Get-Credential -Message "Cred for Azure"
Connect-AzureRmAccount -Credential $credential
Get-AzureRmSubscription

