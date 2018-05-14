function connect-qsazure {
<#
    .Description Looks for json files with
#>
    [CmdletBinding()]
    [Alias("QSconnectAZRM")]
    param (
    )

DynamicParam {
    $attributes = new-object System.Management.Automation.ParameterAttribute
    $attributes.ParameterSetName = "__AllParameterSets"
    $attributes.Mandatory = $true
    $attributeCollection =
      new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
    $attributeCollection.Add($attributes)
    $_Values = try {
            (Get-Content ($env:LOCALAPPDATA + "\qsazure" + "\subscription.json") -ea Stop |
                ConvertFrom-Json).Name
            }Catch{
                    write-warning "Please run Update-QSAzSubscription your subscription file is missing"
                    break
                }
    $ValidateSet =
      new-object System.Management.Automation.ValidateSetAttribute($_Values)
    $attributeCollection.Add($ValidateSet)
    $dynParam1 =
      new-object -Type System.Management.Automation.RuntimeDefinedParameter(
      "Subscription", [string], $attributeCollection)
    $paramDictionary =
      new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
    $paramDictionary.Add("Subscription", $dynParam1)
    return $paramDictionary }

begin {
# Bind the parameter to a friendly variable
$Subscription = $PsBoundParameters.Subscription
$path = ($env:LOCALAPPDATA + "\qsazure")
}



    process {
        Write-Verbose "Your path is: $path"
        Write-Verbose "you selected $Subscription"
        try{
            Test-Path "$path\init.json" -ErrorAction Stop | Out-Null
            Import-AzureRmContext -Path "$path\init.json" -ErrorAction Stop
            Get-AzureRmSubscription -SubscriptionName $Subscription | Select-AzureRmSubscription | Out-Null
            $CContext = Get-AzureRmContext
            $CContext.Account.Id
            $CContext.Subscription.Name
        }catch {
            $Error[0].exception.message
        }

    }

    end {
    }
}