<#
    Create a new Inbound Security Rule on QSVMUEDEVPXY.NSG
#>

QSconnectAZRM -Subscription 'QuarterSpot Bizspark MSDN(Converted to EA)'
Get-AzureRmNetworkSecurityGroup -Name qsvmuedevpxy-nsg -ResourceGroupName qsrgueprdpxy