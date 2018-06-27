function Wait-AzureDSCCompleted
{
    [cmdletbinding()]
    param($MinutesToWait, $ResourceGroup)
    if($MinutesToWait -lt 5)
    {
        throw "Must wait at least five minutes for agent deployment.  Learn some patience."
    }
    $accountName = $ResourceGroup+"-automation-account"
    $foundIt = $false
    $goodtogo = $true

	$sw = [System.Diagnostics.Stopwatch]::StartNew()

    $msg = "Waiting "+ $MinutesToWait +" minutes . . . "
    Write-Verbose $msg

    $waitForIt = $true
    #We have to wait for any active deployments to complete
    while ($true){
        $activedeployments = Get-AzureRmResourceGroupDeployment -ResourceGroupName ($ResourceGroup) | Where-Object ProvisioningState -NotMatch "^Succeeded$"
        if($activedeployments -eq $null)
        {
            if(-Not($waitForIt))
            {
                Write-Verbose "Looks like the deployments are finished and no new ones have started.  Now we'll look at the DSC status."
                break;
            }
            Write-Verbose "It looks like all the deployments are completed.  We'll wait to see if any others start."
            #There can be timing issues between the completion of one deployment and the beginning of the next
            #Because of this we always wait an extra minute after all deployments (that we see) are completed
            #If this causes us to go over the time limit thems' the breaks
            $waitForIt = $false
        }
        else {
            #if this was set to false it means we completed 'all' deployments then started another (or none have completed yet)
            $waitForIt = $true
            Write-Verbose "Waiting 30 seconds then we'll try again if we have time."
        }

        $faileddeployments = $activedeployments | Where-Object ProvisioningState -Match "^Failed$"
        if($faileddeployments -ne $null)
        {
            throw "At least one deployment has failed.  Check the status and retry"
        }

        Start-Sleep -Seconds 30
        if($sw.Elapsed.TotalMinutes -gt $MinutesToWait)
        {
            throw "Deploying the agent took longer than "+$MinutesToWait+".  Aborting deployment."
        }
    }

    #Now we can look to see if the nodes are finished
    while ($true) {

        $nodes = Get-AzureRmAutomationDscNode -ResourceGroupName ($ResourceGroup) -AutomationAccountName ($accountName)

        if($nodes -ne $null)
        {
            $goodtogo = $true
            $foundIt = $true
            foreach($node in $nodes)
            {
                if($node.Status -NotMatch "^Compliant$")
                {
                    $goodtogo = $false
                }
            }

            if($goodtogo)
            {
                return
            }
        }

        if($sw.Elapsed.TotalMinutes -gt $MinutesToWait)
        {
            throw "Deploying the agent took longer than "+$MinutesToWait+".  Aborting deployment."
        }

        Write-Verbose "Waiting 30 seconds then we'll try again if we have time."
        Start-Sleep -Seconds 30
    }

    if($foundIt)
    {
        $msg = "The agent deployment task was found but it took longer than "+$MinutesToWait+" minutes so the function exited."
    }
    else{
        $msg = "The agent deployment task was not found even though the function waited "+$MinutesToWait+" minutes."
    }

    Write-Verbose $msg
}