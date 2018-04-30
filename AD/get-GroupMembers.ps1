function get-GroupMembers {
    <# Getting list of groups in Active directory and returning members
        Users and or Groups
    #>
    [cmdletbinding()]

    param(
        # Parameter help description
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]$Credential
        )

        $Groups = Get-ADGroup -Filter * -Credential $Credential
        foreach ($Group in $Groups){
            Get-ADGroupMember $Group -Credential $Credential| Select-Object name, samaccountname, objectclass |
                Add-Member -MemberType NoteProperty -Name "group" -Value $Group.Name -Force -PassThru
        }
}