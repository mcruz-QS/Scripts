<#
Goal is to move certificates into Azure and provision them to the FrontEnd and BackEnd Servers
Things needed
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Confirm:$false -Force
        test = (Get-PackageProvider | where name -eq "NuGet").version -gt "2.8.5.201"
        get = ((Get-PackageProvider | where name -eq "NuGet").version) -join "."
    Install-Module azurerm -Confirm:$false -Force
        Install-Module azurerm.profile -Confirm:$false -Force
        Install-Module azurerm.KeyVault -Confirm:$false -Force
        test = (get-command Connect-AzureRmAccount).name -eq 'Connect-AzureRmAccount'
        test2 = (get-command Get-AzureRmKeyVault).name -eq 'Get-AzureRmKeyVault'
        get = $((get-command Connect-AzureRmAccount).name + " " + (get-command Get-AzureRmKeyVault).name)
#>
function add-AZCert {
    [CmdletBinding()]
    param(
        $vaultName = $Global:runningConfig.Environment.DeployKeyVault,
        $CertName = ($Global:runningConfig.Environment.Abbr) + "-" + ($Global:runningConfig.Environment.Name),
        $certValidinmonths = (5 * 12) # 5 Years
    )

    begin {

        $SubjectName = "CN=" + $certName + " Data Encryption Authority"
        $certPolicyInfo = @{
            'SubjectName' = $SubjectName
            'IssuerName' = 'Self'
            'ValidityInMonths' = $certValidinmonths
            'KeyType' = 'RSA'
            'KeyUsage' = 'KeyEncipherment'
            'SecretContentType' = 'application/x-pkcs12'
        }
    }
    process {

        $certificatepolicy = New-AzureKeyVaultCertificatePolicy @certPolicyInfo

        $addAZKVCert = Add-AzureKeyVaultCertificate -VaultName $vaultName -Name $CertName -CertificatePolicy $certificatepolicy
        # need to pause while Process runs
        ($addAZKVCert.StatusDetails)
        do {
            Write-Verbose "Sleeping 30 Seconds until Cert is enabled"
            Start-Sleep -Seconds 30
        }until(
            (get-AzureKeyVaultCertificate -VaultName $vaultName -Name $CertName).Enabled -eq $true
        )
    }

    end {
        (get-AzureKeyVaultCertificate -VaultName $vaultName -Name $CertName).Enabled

    }
}



#Make PFX This is the Private Portion of the Certificate
function get-AZCertPFX {
    <#
        .description Get / Download the Azure Certificate PFX File to a local file path

        .example get-AZCertPFX -vaultName aauekvpredeploy -certname pre-Preview -pfxPath c:\temp

    #>
    [CmdletBinding()]
    param (
        [parameter(HelpMessage="Azure Vault Name")]
        [string]$vaultName,
        [parameter(HelpMessage="Azure Cert Name")]
        [string]$certName,
        [parameter(HelpMessage="Path to save PFX File")]
        [string]$pfxPath = "c:\temp\"
    )


    begin {
        if (Test-Path $pfxPath){
            $filePath = (get-item $pfxPath).FullName + "\" + $certName + ".pfx"
        }else{
            write-warning "$pfxPath is Invalid, enter valid path"
            break
        }
        try{
            $kvSecret = Get-AzureKeyVaultSecret -VaultName $vaultName -Name $certName
        }catch{
            $Error[0].exception.message
        }

    }

    process {
        $kvSecretBytes = [System.Convert]::FromBase64String($kvSecret.SecretValueText)
        $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
        $certCollection.Import($kvSecretBytes,$null,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
        $protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, 'test')
        [System.IO.File]::WriteAllBytes($filePath, $protectedCertificateBytes)
    }

    end {
        if (Test-Path $filePath){
            write-verbose "pfx File Created"
        }else{
            Write-Warning "pfx File missing"
        }
    }
}

#make CER This is the Public Portion of the Certificate
function get-AZCertCER {
    [CmdletBinding()]
    param (

    )

    begin {
    }
    $cert = Get-AzureKeyVaultCertificate -VaultName 'VaultFromCode' -Name 'TestCertificate'
    $filePath ='C:\cert\TestCertificate.cer'
    $certBytes = $cert.Certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
    [System.IO.File]::WriteAllBytes($filePath, $certBytes)
    process {
    }

    end {
    }
}


#############
###################################################################
#Generate a Certificate
###################################################################
$certificateName = "test-Preview"
$thumbprint = (New-SelfSignedCertificate -DnsName $certificateName -CertStoreLocation Cert:\CurrentUser\My -KeySpec KeyExchange).Thumbprint
$cert = (Get-ChildItem -Path cert:\CurrentUser\My\$thumbprint)
$password = ConvertTo-SecureString -AsPlainText "This1sat3st!" -Force
Export-PfxCertificate -Cert $cert -FilePath ".\$certificateName.pfx" -Password $password

##################################################################
#Login and Select Subscription
##################################################################

#Login-AzureRmAccount
#Get-AzureRmSubscription
#Select-AzureRmSubscription -SubscriptionID XXXXXXXXXXXXXXXXXXXXXXXXXXXX

##################################################################
#Create Keyvault and Upload Certificate to Vault
##################################################################

$vaultName = "pauekvpredeploy"
# $CertRG = "pauergpremanagement000"
# $location = "East US"
$secretName = "test-Preview"
$certPassword = $password
$fileName = "test-Preview.pfx"
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
$fileContentBytes = Get-Content $fileName -Encoding Byte
$fileContentEncoded = [System.Convert]::ToBase64String($fileContentBytes)

$jsonObject = @"
{
  "data": "$fileContentEncoded",
  "dataType" :"pfx",
  "password": "$certPassword"
}
"@

$jsonObjectBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonObject)
$jsonEncoded = [System.Convert]::ToBase64String($jsonObjectBytes)

# New-AzureRmResourceGroup -Name $resourceGroup -Location $location
# New-AzureRmKeyVault -VaultName $vaultName -ResourceGroupName $resourceGroup -Location $location -sku standard -EnabledForDeployment

$certname = $secretName
$secret = ConvertTo-SecureString -String $jsonEncoded -AsPlainText –Force
Set-AzureKeyVaultSecret -VaultName $vaultName -Name $certificateName -SecretValue $secret


###################################################################
#Upload Certificate to VM
###################################################################

# $subId = (Get-AzureRmContext).Subscription.SubscriptionId
$vmRGName = 'pauergpre000'
$vmName = 'pauevmprebkd000'

$vm = Get-AzureRmVM -ResourceGroupName $vmRGName -Name $vmName

$SourceVaultId = (Get-AzureRmKeyVault -VaultName $vaultName).ResourceId
$certStore = "My";
$certUrl = (Get-AzureKeyVaultSecret -VaultName $vaultName -Name $certname).Id;
$AddvmCert = Add-AzureRmVMSecret -VM $vm -SourceVaultId $SourceVaultId -CertificateStore $certStore -CertificateUrl $certUrl;
$AddvmCert
Update-AzureRmVM -ResourceGroupName $vmRGName -VM $AddvmCert