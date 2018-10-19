<#
    Copy the files to the desktop
#>

$password = Read-Host -Prompt "EnterPassword" -AsSecureString
# Do not continue until password is entered

$certs = Get-ChildItem "$env:USERPROFILE\Desktop" | where-object {($_.name -match ".crt") -or ($_.name -match ".p7b")}

$pfx = Get-ChildItem "$env:USERPROFILE\Desktop" | where-object {($_.name -match ".pfx") }

$store = "Cert:\LocalMachine\My"

$certs | ForEach-Object {
    Import-Certificate -FilePath $_.FullName -CertStoreLocation $store
}


$Thumbprint = (Import-PfxCertificate -Exportable -Password $password -CertStoreLocation $store -FilePath $pfx.FullName).Thumbprint


Import-Module WebAdministration
$oldBindings = Get-ChildItem -Path IIS:SSLBindings | ForEach-Object -Process {
    if ($_.Sites) {
        $certificate = Get-ChildItem -Path CERT:LocalMachine/My |
            Where-Object -Property Thumbprint -EQ -Value $_.Thumbprint
            [PsCustomObject]@{
                Sites = $_.Sites.Value
                CertificateFriendlyName = $certificate.FriendlyName
                CertificateDnsNameList = $certificate.DnsNameList
                CertificateNotAfter = $certificate.NotAfter
                CertificateIssuer = $certificate.Issuer
                PSChildName = $_.PSChildName
            }
    }
}
$oldBindings

# [System.Runtime.InteropServices.marshal]::PtrToStringAuto([System.Runtime.InteropServices.marshal]::SecureStringToBSTR($password))
 foreach ($binding in $OldBindings) {
    #remove old Binding
    Get-Item -path "IIS:\SslBindings\$($binding.PSChildName)" | Remove-Item
    #add new Binding
    Get-Item Cert:\LocalMachine\My\$Thumbprint | New-Item -Path "IIS:\SslBindings\$($binding.PSChildName)"
}

$newBindings = Get-ChildItem -Path IIS:SSLBindings | ForEach-Object -Process {
    if ($_.Sites) {
        $certificate = Get-ChildItem -Path CERT:LocalMachine/My |
            Where-Object -Property Thumbprint -EQ -Value $_.Thumbprint
            [PsCustomObject]@{
                Sites = $_.Sites.Value
                CertificateFriendlyName = $certificate.FriendlyName
                CertificateDnsNameList = $certificate.DnsNameList
                CertificateNotAfter = $certificate.NotAfter
                CertificateIssuer = $certificate.Issuer
            }
    }
}
$newBindings

$certs.FullName | ForEach-Object {Remove-Item $_ -Force}
$pfx.FullName | ForEach-Object { Remove-Item $_ -Force}

start-sleep -Seconds 5
logoff.exe