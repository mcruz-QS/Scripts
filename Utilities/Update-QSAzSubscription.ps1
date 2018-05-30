function Update-QSAzSubscription {
<#
    .Description Builds init files
#>
[CmdletBinding()]
[Alias("QSSubUpAZ")]
param(

)
begin{
    $path = ($env:LOCALAPPDATA + "\qsazure")
}
Process{
    write-verbose "The path is: $path"
    try{
        if (!(test-path $path)){
            New-Item -Path $path -ItemType "Directory" -ErrorAction stop -force| Out-Null
        }

        Connect-AzureRmAccount
        Save-AzureRmContext -Path "$path\init.json" -Force
        Get-AzureRmSubscription | ConvertTo-Json | Out-File "$path\subscription.json" -Force

    }catch
    {
        $Error[0].Message
    }

}
End{

}
}