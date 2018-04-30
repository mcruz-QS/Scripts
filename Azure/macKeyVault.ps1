
try {
    Get-AzureRmSubscription -ErrorAction Stop | Out-Null
} catch {
    "No Azure Subscription available, Please Login"
    Login-AzureRmAccount
}
try {
     "Current Guid is " + $(Get-Variable guid -ErrorAction Stop).Value
} catch {
    # some cmdlets don't support names with -'s or more than 
    "Guid Variable is not available, Creating new guid"
    $guid = ($(New-Guid).Guid -split "-")[0]
    "New Short Guid is $guid"
}



$kvName = 'mac' + $guid + 'KV'
$rgName = 'mac' + $guid +'RG'
$location = 'East US'
$aadClientSecret ='macClientSecret'
$appDisplayName = 'macEncryptApp'

New-AzureRmResourceGroup -na $rgName -Location $location
Get-AzureRmResourceGroup -Name $rgName
New-AzureRmKeyVault -VaultName $kvName -ResourceGroupName $rgName -Location $location
Get-AzureRmKeyVault -VaultName $kvName

# this is a test
Set-AzureRmKeyVaultAccessPolicy -VaultName $kvName -ResourceGroupName $rgName -EnabledForDiskEncryption

$aadApp = New-AzureRmADApplication -DisplayName $appDisplayName -HomePage "http://cruz3r.com/app" -IdentifierUris "http://cruz3r.com/appuri" -Password (ConvertTo-SecureString -AsPlainText $aadClientSecret -Force)

$aapID = $($aadApp.ApplicationId).Guid

$aadServicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $appID

Set-AzureRmKeyVaultAccessPolicy -VaultName $kvName -ServicePrincipalName $aapID -PermissionsToKeys all -PermissionsToSecrets all


# this is my area to test