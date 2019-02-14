<#
 Move to Cleanup OU
 This is for users that are disabled in AD

#>
# Requires login for Exchange and ms online
$ex = New-PSSession -ConfigurationName Microsoft.Exchange `
    -ConnectionUri https://outlook.office365.com/powershell -Credential (Import-Clixml C:\fso\cred.xml) `
    -Authentication basic -AllowRedirection
Import-PSSession $ex

Connect-MsolService

$ErrorActionPreference = "Stop"

# Locations where we store Users
$listBases =@("Lincoln","NY","S1","TX","Virginia") # Lincoln is Nelnet
$SearchBases = $listBases | foreach {Get-ADOrganizationalUnit -Filter "name -eq `'$_`'"}
# Destination of OU
$CleanUpOU = "OU=Cleanup,DC=QuarterSpot,DC=local"

$list = foreach ($base in $SearchBases){
    Try{
        get-aduser -filter {enabled -eq $false} -Properties whenchanged -SearchBase $base  | 
            Add-Member -MemberType NoteProperty -Name "OU" -Value $base -Force -PassThru #|
               Set-ADUser -Identity $_.SamAccountName -Description "$($_.whenchanged) $($_.OU)"
        }
    catch{
        $error[0].exception.Message
    }

}

# Gets Mailboxes 
$Mailboxes = foreach ($name in $list) {
    try{
        Get-Mailbox -Identity $name.userprincipalname -erroraction stop | select recipienttype, 
            recipienttypedetails, EffectivePublicFolderMailbox, PrimarySmtpAddress
    }catch{
        Write-Warning "Missing " + $name.userprincipalname
    }
}

# Set Mailboxes to shared Mailbox
$Mailboxes | foreach { if ($_.Recipienttypedetails -eq "UserMailbox"){
    try {
        Set-Mailbox -Identity $_.PrimarySmtpAddress -type "shared"
        }
    catch{
        write-warning "Set mailbox failed on" + $_.PrimarySMTPAddress
    }
    }
}

# Will remove Licenses
$Mailboxes | foreach { 
    $upn = $null
    $upn = $_.primarysmtpaddress
    $licenses = $(Get-MsolUser -UserPrincipalName $upn).licenses.accountskuid  
    $licenses | foreach {
            Set-MsolUserLicense -UserPrincipalName $upn -RemoveLicenses $_ -Verbose 
        }
    # Keeps track of what was worked on
    $AcctInfo = $null
    $AcctInfo = [PSCustomObject] @{Account=$upn;Licenses=($licenses -join ";");Mailbox=((get-mailbox $upn).RecipientTypeDetails)}
    $AcctInfo | Export-Csv ConvertedMailboxes.csv -Append -NoTypeInformation
}

# Change Description
 $list | select samaccountname, DistinguishedName, whenchanged, ou | foreach {Set-ADUser -Identity $_.samaccountname -
Description "$($_.whenchanged) $($_.OU)"}

# Move users to cleanupou 
$list | foreach {  get-aduser -Identity $_.SamAccountName | foreach {Move-ADObject -Identity $_.DistinguishedName -TargetPath $CleanUpOU}}