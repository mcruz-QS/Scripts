function Add-AZNSG {
    [CmdletBinding()]
    param (
        [string]$Environment = $Global:runningConfig.Environment.Name,
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$Name,
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$IPAddress,
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string[]]$Description

    )

    begin {
        try{
            write-verbose "Starting Add AZNSG"
            Get-AzureRmSubscription -SubscriptionName 'QuarterSpot Bizspark MSDN(Converted to EA)' |
                Select-AzureRmSubscription | Out-Null
            $AZNSG = Get-AzureRmNetworkSecurityGroup -Name $NSG -ResourceGroupName $ResourceGroup
            if($Environment -eq "Production"){
                $ResourceGroup = 'QSRGUEPRDPXY'
                $NSG = 'qsvmueprdpxy-nsg'
            }else{
                $ResourceGroup = 'QSRGUEPRDPXY'
                $NSG = 'qsvmuedevpxy-nsg'
            }
        }catch{
            Write-warning "Could not access NSG"
        }
    }

    process {
        try{
            $Priority = Get-AzureRmNetworkSecurityGroup -Name  'qsvmuedevpxy-nsg' -ResourceGroupName 'QSRGUEPRDPXY'
            do {$newPri = $Priority.SecurityRules.priority[-1] + 10}until ($Priority.SecurityRules.priority -notmatch $newPri)
        # IPAdress is listed as CIDR with only one IP address range

            $addAZNSGRuleConfig = @{
                Name = $Name
                Description = $Description
                Access = 'Allow'
                Protocol = 'Tcp'
                Direction = 'Inbound'
                SourceAddressPrefix = "$IPAddress/32"
                SourcePortRange = '*'
                DestinationAddressPrefix = '*'
                DestinationPortRange = '8443'
                Priority = $newPri
            }
        }catch{
            $Error[0].exception.message
        }
    }

    end {
        try{
        Get-AzureRmNetworkSecurityGroup -Name  'qsvmuedevpxy-nsg' -ResourceGroupName 'QSRGUEPRDPXY' |
        Add-AzureRmNetworkSecurityRuleConfig @addAZNSGRuleConfig |
        Set-AzureRmNetworkSecurityGroup

        Get-AzureRmSubscription -SubscriptionId $Global:runningConfig.Azure.Subscription |
            Select-AzureRmSubscription | Out-Null
        }catch{
            Write-warning "Failed to write $Description"
        }
    }
}


function Get-AZPublicIPResGrp {
    [CmdletBinding()]
    param (
        $ResourceGroup = $Global:runningConfig.Azure.ResourceGroup
    )

    begin {
        try{
        write-verbose "Starting Get-AZPublicIPResGrp"
        Get-AzureRmSubscription -SubscriptionId $Global:runningConfig.Azure.Subscription |
            Select-AzureRmSubscription | Out-Null
        $IPAddress = Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup | select Name, IpAddress
        }catch{
            Write-warning "Could not access PublicIPAddress"
            break
        }
    }

    process {
        $Data += foreach ($IP in $IPAddress) {
            if($IP.Name -match 'ftd'){
                $Name = $ResourceGroup + "_ftd"
            }elseif ($IP.Name -match 'bkd') {
                $Name = $ResourceGroup + "_bkd"
            }
            $Description = "AZure resource group $ResourceGroup"
             [PSCustomObject]@{
                Name = $Name
                IPAddress = $IP.IpAddress
                Description = $Description
            }

            # Add-AZNSG -Name $Name -IPAddress $IP.IpAddress -Description
        }
    }

    end {
        return $Data
    }
}

function Add-AZSqlFireWallRules {
    [CmdletBinding()]
    param (
        $ResourceGroup = $Global:runningConfig.Azure.ResourceGroup
    )

    begin {
        $ResourceType =  'Microsoft.Sql/servers'
        try{
            Get-AzureRmSubscription -SubscriptionId $Global:runningConfig.Azure.Subscription |
                Select-AzureRmSubscription | Out-Null
            $Servers = Get-AzureRmResource -ResourceGroupName $ResourceGroup -ResourceType $ResourceType
        }catch{
            Write-warning "Unable to access resource"
            break
        }
    }

    process {
        foreach ($Server in $Servers){
            write-verbose "Creating FW rule for $($Server.name)"
            # Get-AzureRmSqlServerFirewallRule -ServerName $Server.Name -ResourceGroupName $ResourceGroup
            $FW1 = @{
                'ResourceGroupName' = $ResourceGroup
                'ServerName' = $Server.Name
                'FirewallRuleName' = "Austin Lakeline ATTtest"
                'StartIpAddress' = "45.25.134.49"
                'EndIpAddress' = "45.25.134.54"
                }

            $FW2 = @{
                'ResourceGroupName' = $ResourceGroup
                'ServerName' = $Server.Name
                'FirewallRuleName' = "Austin Lakeline TWCtest"
                'StartIpAddress' = "71.78.120.113"
                'EndIpAddress' = "71.78.120.114"
            }
            New-AzureRmSqlServerFirewallRule @FW1
            New-AzureRmSqlServerFirewallRule @FW2
        }
    }

    end {
    }
}


Get-AZPublicIPResGrp | Add-AZNSG

Add-AZSqlFireWallRules

#  put them in AZConfigUtils