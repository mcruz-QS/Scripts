
function add-CertPermission{
    [CmdletBinding()]
   param(
   [Parameter(Mandatory=$true)                   ]
       $subject,
       $userGroup = 'NETWORK SERVICE'
   )
       Write-Host "Checking permissions to certificate $subject.." -ForegroundColor DarkCyan

       $cert = (gci Cert:\LocalMachine\My\ | where { $_.Subject -match $subject })[-1]
       $certHash = $cert.Thumbprint
       $certSubject = $cert.Subject
       $keyName=$cert.PrivateKey.CspKeyContainerInfo.UniqueKeyContainerName
       $keyPath = "C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys\"
       $fullPath=$keyPath+$keyName
       $acl=(Get-Item $fullPath).GetAccessControl('Access')

       $hasPermissionsAlready = ($acl.Access | where {$_.IdentityReference.Value.Contains(
           $userGroup.ToUpperInvariant()) -and $_.FileSystemRights -eq [System.Security.AccessControl.FileSystemRights]::FullControl}).Count -eq 1

       if ($hasPermissionsAlready){
           Write-Host "Certificate '$subject' already has the full permissions to group $userGroup." -ForegroundColor Green
           return $true;
       } else {
           Write-Host "Need add permissions to '$subject' certificate.." -ForegroundColor DarkYellow

           $permission=$userGroup,"Full","Allow"
           $accessRule=new-object System.Security.AccessControl.FileSystemAccessRule $permission
           $acl.AddAccessRule($accessRule)
           Set-Acl $fullPath $acl

           Write-Output "Permissions were added"
           return (Get-Acl $fullPath).Access | where Identityreference -Match $userGroup;

       }
}