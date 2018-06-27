

(Get-AzureRmResourceGroup -Name chuergfpd000 | Get-AzureRmNetworkInterface)
(Get-AzureRmResourceGroup -Name chuergfpd000 | Get-AzureRmNetworkSecurityGroup)

| foreach {Set-AzureRmNetworkInterface -NetworkInterface $_}

8 $a.networksecuritygroup | foreach {$_ = $b.name}
  39 $a.networksecuritygroup
  40 $a = (Get-AzureRmResourceGroup -Name chuergfpd000 | Get-AzureRmNetworkInterface)
  41 foreach ($Nic in $a) {$Nic}
  42 foreach ($Nic in $a) {$Nic.NetworkSecurityGroup = $b.Name}
  43 foreach ($Nic in $a) {$Nic.NetworkSecurityGroup = $($b.Name)}
  44 foreach ($Nic in $a) {$Nic.NetworkSecurityGroup = $b}
  45 $Nic
  46 $Nic.NetworkSecurityGroup
  47 $a.NetworkSecurityGroup
  48 Set-AzureRmNetworkInterface -NetworkInterface $a
  49 $a | foreach {Set-AzureRmNetworkInterface -NetworkInterface $_}
  50 history
  51 $c = Get-AzureRmNetworkSecurityGroup -Name chuergfpd000
  52 $c = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $(Get-AzureRmResourceGroup  "chuergfpd000")
  53 $b
  54 history
  55 $b = (Get-AzureRmResourceGroup -Name chuergfpd000 | Get-AzureRmNetworkSecurityGroup)