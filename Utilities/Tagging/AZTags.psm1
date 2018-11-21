<#
    Need a function to set tags for  the following
    Environment = Production, Preview, Release, Training, Develop
    Account = QuarterSpot, Sonas, DCU, Aperia
    Status = Active, Decom, Provisioning
    Exapmle C:\Users\m.cruz\Documents\git\Scripts\Utilities\Tagging\Tagging.ps1

#>
function Set-AZTags {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,
            HelpMessage="Select Environment 'Production','Preview','Release','Training','Develop'")]
        [ValidateSet('Production','Preview','Release','Training','Develop')]
        $Environment,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage="Provide the Account this falls under" )]
        $Account,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage="Select status for 'Active','Decom','Pending'")]
        [ValidateSet('Active','Decom','Pending')]
        $Status,

        [Parameter(Mandatory=$false,HelpMessage="Provide Credential if needed")]
        [System.Management.Automation.PSCredential]$credential,

        [Parameter(Mandatory=$true,ValueFromPipeline=$true,HelpMessage="requires ResourceGroupName to Add Tags")]
        $ResourceGroupName,

        [Parameter(Mandatory=$false,ValueFromPipeline=$true,HelpMessage="requires ResourceName to Add Tags")]
        [String[]]$Resources,

        [Parameter(Mandatory=$false,HelpMessage="Needs ResourceGroupName to list all resources and tags")]
        $subscription = 'LASO Development'
    )

    begin {
        if ($credential){
            $connectioninfo = Connect-AzureRmAccount -Credential $Credential -Subscription $subscription

        }
    }

    process {
        if ($ResourceGroupName){
            try{
                Get-AzureRmResourceGroup -ResourceGroupName $ResourceGroupName  | Set-AzureRmResourceGroup -Tag @{
                    "Environment"=$Environment;
                    "Account"=$Account;
                    "Status"=$Status;
                    "Type"="ResourceGroup"
                }
            }catch{
                $msg = ($Error[0].exception.message)
                write-warning $msg
            }
        }
        if ($Resources){
            foreach ($Resource in $Resources){
                try{
                    Write-Verbose $Resource -Verbose
                    $res = $null
                    $res = Get-AzureRmResource -Resourcename $Resource -ResourceGroupName $ResourceGroupName
                    if (($res | where Resourcetype -ne "Microsoft.Sql/servers/databases") -and ($res | where Resourcetype -NotMatch "/master")){
                        Set-AzureRmResource -ResourceGroupName $res.ResourceGroupName -Tag @{
                            "Environment"=$Environment;
                            "Account"=$Account;
                            "Status"=$Status;
                            "Type"=$res.ResourceType
                        } -ResourceName $res.Name -ResourceType $res.ResourceType -Force -Confirm:$False | Out-Null
                    }

                }catch{
                    $msg = ($Error[0].exception.message)
                    write-warning $msg

                    write-information -messagedata "
                    You are in `'$($connectioninfo.Context.Subscription.Name)`' Subscription
                    Use: 'Get-AzureRmSubscription -SubscriptionName `'Name`' for list of subscriptions'
                    to change subscriptions
                    " -InformationAction Continue
                    $ErrorActionPreference = "Stop"
                }
            }
        }
    }

    end {
        if ($Resources){
            foreach ($Resource in $Resources){
                try{
                    Get-AzureRmResource -Resourcename $Resource -ResourceGroupName $ResourceGroupName| select Name, Tags
                }catch{
                    $msg = ($Error[0].exception.message)
                    write-warning $msg
                }
            }
            if ($ResourceGroupName){
                try{
                    Get-AzureRmResourceGroup -ResourceGroupName $ResourceGroupName | select Name, Tags
                }catch{
                    $msg = ($Error[0].exception.message)
                    write-warning $msg
                }
            }
        }
    }
}

function Get-AZResTags {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false,HelpMessage="Provide Credential if needed")]
        [System.Management.Automation.PSCredential]$credential,
        [Parameter(Mandatory=$true,HelpMessage="Needs ResourceGroupName to list all resources and tags")]
        $ResourceGroupName,
        [Parameter(Mandatory=$true,HelpMessage="Needs ResourceGroupName to list all resources and tags")]
        $subscription = 'LASO Development'

    )

    begin {
        if ($credential){
            $connectioninfo = Connect-AzureRmAccount -Credential $Credential -Subscription $subscription

            write-information -messagedata "
            You are in `'$($connectioninfo.Context.Subscription.Name)`' Subscription
            Use: 'Get-AzureRmSubscription -SubscriptionName `'Name`' for list of subscriptions'
            to change subscriptions
            " -InformationAction Continue
        }
    }

    process {
        $ErrorActionPreference = "Stop"
        try{
            Get-AzureRmResource -ResourceGroupName $ResourceGroupName | select name, tags, ResourceType, location, ResourceID, ResourceGroupName
        }catch{
            $msg = ($Error[0].exception.message)
            write-warning $msg
            write-information -messagedata "
            You are in `'$($connectioninfo.Context.Subscription.Name)`' Subscription
            Use: 'Get-AzureRmSubscription -SubscriptionName `'Name`' for list of subscriptions'
            to change subscriptions
            " -InformationAction Continue
        }
    }


    end {
    }
}