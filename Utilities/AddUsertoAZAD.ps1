<#
    This is to add users to the New ActiveDirectory Subscription once it is created.
    The example is for QA at this time 

#>

# Create an empty collection
$namesAD = New-Object System.Collections.ArrayList
# example of getting names
$names = ("amy","mayra","Ariana")
$names | foreach {
    $namesAD.Add((get-aduser -Filter{givenname -eq $_} | select name, userprincipalname))
}
# login to Azure
$azureCred = Get-Credential
# connect to the right Tenant
connect-azuread -Credential $azureCred -TenantId 75e2b040-a4f7-4e10-b202-1cd47717e8f2 #did not see how to get tenantid

$namesAD | foreach {
    New-AzureADMSInvitation -InvitedUserDisplayName ($_.name) -InvitedUserEmailAddress ($_.userprincipalname) -SendInvitationMessage $true `
        -InviteRedirectUrl 'https://uiautomation-release-admin.apply.loan/'
}

# Add Users to Application Administrator Group
$newADUsers = Get-AzureADUser | where userType -eq "guest"


foreach ($newADUser in $newADUsers){
    $role = Get-AzureADDirectoryRole | Where-Object {$_.displayName -eq 'Application Administrator'}
    if (($role | Get-AzureADDirectoryRoleMember).objectid -notcontains $newADUser.ObjectID){
        Add-AzureADDirectoryRoleMember -ObjectId $role.ObjectId -RefObjectId $newADUser.ObjectId
    }else{$newADUser.DisplayName + " in " + $role.DisplayName }
}