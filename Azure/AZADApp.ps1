<#
needs to use AzureAD instead of AzureRM
set's Windows Azure Active Directory in AD Application
#>
Function Set-AZApplicationDelegatedPermissions{
    [cmdletbinding()]
    param(
        [string]$tenantID = ($Global:runningConfig.Azure.ADApp.ADTenantId),
        $credential = $credential,
        $ADAppId =  $Global:runningConfig.Azure.ADApp.Id
    )
    write-verbose "Setting Application Delegation Permissions"
    try{
        Connect-AzureAD -TenantId ($tenantID) -Credential $credential | out-null

        $app = Get-AzureADApplication -ObjectId (Get-AzureADApplication | where AppId -eq $ADAppId).ObjectId

        $req = '{
            "ResourceAppId":  "00000002-0000-0000-c000-000000000000",
            "ResourceAccess":  [
                                {
                                    "Id":  "cba73afc-7f69-4d86-8450-4978e04ecd1a",
                                    "Type":  "Scope"
                                },
                                {
                                    "Id":  "311a71cc-e848-46a1-bdf8-97ff7156d8e6",
                                    "Type":  "Scope"
                                },
                                {
                                    "Id":  "a42657d6-7f20-40e3-b6f0-cee03008a62a",
                                    "Type":  "Scope"
                                }
                            ]
        }' | convertfrom-json
        Set-AzureADApplication -ObjectId $app.ObjectId -RequiredResourceAccess $req
    }catch{
        write-warning "Failed to set Application Delegation Permissions"
        $error[0].exception.message
    }
}
