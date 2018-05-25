function Wait-UntilOctopusMachinesHealthy {
    [CmdletBinding()]
    param (
        [string]$OctopusURL = $($global:runningConfig.Octopus).OctopusServerUri,
        [string]$OctopusAPIKey = $($global:runningConfig.Octopus).OctopusAPIKey,
        [string]$azuremachinesAbbr = $($global:runningConfig.Inputs.tenant + $global:runningConfig.Azure.LocAbbr+ "vm" + $global:runningConfig.Environment.Abbr)
    )

    begin {
        Write-verbose "Wait-UntilOctopusMachinesHealthy"
    }

    process {
        # Set-Location "${env:ProgramFiles}\Octopus Deploy\Tentacle"
        Add-Type -Path "${env:ProgramFiles}\Octopus Deploy\Tentacle\Newtonsoft.Json.dll"
        Add-Type -Path "${env:ProgramFiles}\Octopus Deploy\Tentacle\Octopus.Client.dll"
        $i = 0

        $endpoint = new-object Octopus.Client.OctopusServerEndpoint $OctopusURL,$OctopusAPIKey
        $repository = new-object Octopus.Client.OctopusRepository $endpoint
        $findMachine = $repository.Machines.FindAll() | where { ($_.name -Match "$azuremachinesAbbr") -and ($_.status -ne "Disabled")}
        write-verbose "found $($findMachine.count) machines"
        # (40 * 90 = 3600) = 60 Minutes
        do {
            if($findMachine.HealthStatus -notcontains "Healthy"){
                $i++
                Write-verbose "Sleeping for 90 Seconds $($i -40) more times or until all are Healthy"
                start-sleep -seconds 90

                $findMachine = $repository.Machines.FindAll() | where { ($_.name -Match "$azuremachinesAbbr") -and ($_.status -ne "Disabled")}
            }else{
                write-verbose "Continue Wait-UntilOctopusMachinesHealthy"
                $i = 40
            }
        }until(
            $i -ge 40
        )

    }

    end {
        $findMachine | foreach-object {
            write-verbose $($_.Name + " " + $_.Status + " " + $_.HealthStatus)
        }
        $true

    }
}