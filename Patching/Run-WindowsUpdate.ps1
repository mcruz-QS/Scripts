#Download and install software updates from WU that are selected by default
#v1.1 12/17/2012
#To skip any updates that will be installed, create a text file called updatestoskip.txt
#in the same directory as this script, listing one KB article number per line, starting
#on the second line.  (The first line is for these instructions.)

function WriteEvent ($eventMessage,$eventType,$eventID)
	{
	$sourceName = 'QSTeam Scripts'
	if (-not([System.Diagnostics.EventLog]::SourceExists($sourceName)))
		{
		[System.Diagnostics.EventLog]::CreateEventSource($sourceName,'Application')
		}
	$EventLog = New-Object System.Diagnostics.EventLog('Application')
	$eventLogType = [System.Diagnostics.EventLogEntryType]::$eventType
	$EventLog.Source = $sourceName
	$EventLog.WriteEntry($eventMessage,$eventLogType,$EventID)
	}

function Get-UpdatesToSkip
	{
	$scriptDirectory = Split-Path $script:MyInvocation.MyCommand.Path
	$KB = @()
	if (Test-Path "$scriptDirectory\updatestoskip.txt")
		{
		$sourceFile = Get-Content "$scriptDirectory\updatestoskip.txt"
		if ($sourceFile.Length -gt 1)
			{
			for ($i = 1;$i -le $sourceFile.Length - 1;$i++)
				{
				$KB += $sourceFile[$i]
				}
			}
		}
	$KB
	}

#Software updates only, selected by default, not already installed
$criteria="IsInstalled=0 and Type='Software' and AutoSelectOnWebSites=1"
$resultcode= @{0="Not Started"; 1="In Progress"; 2="Succeeded"; 3="Succeeded With Errors"; 4="Failed" ; 5="Aborted" }
$updateSession = New-Object -ComObject 'Microsoft.Update.Session'
WriteEvent 'Windows Update process is starting.' 'Information' '1000'
WriteEvent "Beginning check for available updates based on the following criteria: $criteria." 'Information' '1001'
$updates = $updateSession.CreateupdateSearcher().Search($criteria).Updates
if ($updates.Count -eq 0)
	{
	WriteEvent 'Check for available updates is complete.  There are no updates to apply.' 'Information' '1001'
	}
else
	{
	WriteEvent "Check for available updates is complete.  There are $($updates.Count) updates to apply." 'Information' '1001'
	#Create download object
	$updatesToDownload = New-Object -ComObject 'Microsoft.Update.UpdateColl'
	$downloader = $updateSession.CreateUpdateDownloader()
	#Build download collection, skipping specified KBs from file
	$updatesToSkip = Get-UpdatesToSkip
	$updates | ForEach-Object {
		if ($updatesToSkip -match $_.KBArticleIDs)
			{
			WriteEvent "Skipping download of $($_.KBArticleIDs) since it is listed in the file of updates to skip." 'Information' '1001'
			}
		else
			{
			$updatesToDownload.Add($_) | Out-Null
			}
		}
	if ($updatesToDownload.Count -eq 0)
		{
		WriteEvent 'After excluding updates to skip, there are no updates to apply.' 'Information' '1001'
		}
	else
		{
		$downloader.Updates = $updatesToDownload
		WriteEvent 'Beginning download of available updates.' 'Information' '1002'
		$result = $downloader.Download()
		if (($result.Hresult -eq 0) -and (($result.resultCode -eq 2) -or ($result.resultCode -eq 3)))
			{
			WriteEvent 'Download of available updates has completed.' 'Information' '1002'
			$updatesToInstall = New-Object -ComObject 'Microsoft.Update.UpdateColl'
			$updates | Where-Object {$_.isdownloaded} | Foreach-Object {$updatesToInstall.Add($_) | Out-Null}
			#Create installer object
			$installer = $updateSession.CreateUpdateInstaller()
			$installer.Updates = $updatesToInstall
			WriteEvent "Beginning installation of downloaded updates `($($installer.Updates.count)`)." 'Information' '1003'
	        #Run installation of downloaded files
			$installationResult = $installer.Install()
	        $global:counter=-1
	        $installResults = $installer.updates | Select-Object -property Title,EulaAccepted,@{label='Result'; `
				expression={$resultCode[$installationResult.GetUpdateResult($($global:counter++)).resultCode]}}
			WriteEvent ($installResults | Format-Table -Wrap | Out-String) 'Information' '1002'
			}
		else
			{
			WriteEvent 'Error downloading updates.' 'Warning' '1001'
			}
		}
	}
WriteEvent 'Windows Update process is complete.' 'Information' '1010'
