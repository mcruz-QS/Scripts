function invoke-rdp {
<#
Gets AD Domain Controllers and allows you to RDP to them with set window size
#>
[CmdletBinding()]
[Alias("RDP")]
param(
    [Parameter(
        HelpMessage="Width of Screen"
    )]
    $width = "1280",
    [Parameter(
        HelpMessage="Height of Screen"
    )]
    $height = "1024"
    <#[Parameter(
        Mandatory=$true,
        HelpMessage="List of Servers"
    )]
    [ValidateSet("QSVMUEDC01","QSVA-DC01","AUS-DC01","QSNY-DC02","QSVMUEDCADC01")]
    $ComputerName
    #>

)
DynamicParam {
    $attributes = new-object System.Management.Automation.ParameterAttribute
    $attributes.ParameterSetName = "__AllParameterSets"
    $attributes.Mandatory = $true
    $attributeCollection =
      new-object -Type System.Collections.ObjectModel.Collection[System.Attribute]
    $attributeCollection.Add($attributes)
    $_Values = (Get-ADDomainController -Filter * | Select-Object name).name
    $ValidateSet =
      new-object System.Management.Automation.ValidateSetAttribute($_Values)
    $attributeCollection.Add($ValidateSet)
    $dynParam1 =
      new-object -Type System.Management.Automation.RuntimeDefinedParameter(
      "ComputerName", [string], $attributeCollection)
    $paramDictionary =
      new-object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
    $paramDictionary.Add("ComputerName", $dynParam1)
    return $paramDictionary }

begin {
# Bind the parameter to a friendly variable
$ComputerName = $PsBoundParameters.ComputerName
}

process {
# Your code goes here

    mstsc /v:$ComputerName /w:$width /h:$height
}

}