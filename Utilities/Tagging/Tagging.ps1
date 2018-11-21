$accountName = 'UIAutomation'
$a = @{}
$a.rg = 'uiuergrel000'
$a.sub = 'LASO Development'
# $($sub | Where-Object {$_.name -Match "dev"}).name
Connect-QSAzure  -Subscription $a.sub
$resources = Get-AZResTags -subscription $a.sub -ResourceGroupName $a.RG


<#
Set-AZTags -Environment Develop -Account $accountName -Status Active -ResourceGroupName $a.rg -subscription $a.sub -Resources $resources.name
Choices of -Environment
Develop
Preview
Production
Release
Training
#>
Set-AZTags -Environment Release -Account $accountName -Status Active -ResourceGroupName $a.rg -subscription $a.sub -Resources $resources.name