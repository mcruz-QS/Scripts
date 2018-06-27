function Wait-Async
{
    [cmdletbinding()]
    param($context)
    $RunspacePool = $context.Runspacepool
    $Jobs = $context.Jobs

	Write-Verbose "Waiting on Jobs . . . "
	Do {
		Write-Verbose "still waiting . . . "
		Start-Sleep -Seconds 30
	} While ( $Jobs.Result.IsCompleted -contains $false)
	Write-Verbose " completed!"

	$Results = @()
	ForEach ($Job in $Jobs)
	{
        $Results+=@{
            Output=$job.Output
            Debug=$job.Pipe.Streams.Debug.ReadAll()
            Error=$job.Pipe.Streams.Error.ReadAll()
            Verbose=$job.Pipe.Streams.Verbose.ReadAll()
            Information=$job.Pipe.Streams.Information.ReadAll()
            Warning=$job.Pipe.Streams.Warning.ReadAll()
            }

	}
    foreach($result in $results){
        # foreach($output in $result.Output){
        #     $output
        # }
        foreach($output in $result.Verbose){
            $output | out-string  | Write-Verbose
        }
        foreach($output in $result.Error){
            Write-Error $output
        }
        foreach($output in $result.Warning){
            $output | Out-String | Write-Warning
        }
        foreach($output in $result.Information){
            $output | Out-String | Write-Information
        }

    }
    return ($results.GetEnumerator() | %{$_.Output} )

	$RunspacePool.Dispose()
    "Completed running jobs in " + $context.Timmer.Elapsed | Write-Verbose
}