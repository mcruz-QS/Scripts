Script InstallOctoCalamari
			{
				GetScript = {
                    $path = "c:\Octopus\Calamari"
					if (test-path $path){
                        $octoConfig = (Get-ChildItem "C:\Octopus\Calamari").name
					}else{
						$octoConfig = "Calamari folder missing"
					}
					return @{ 'Result' = $octoConfig }
				}

				SetScript = {

                    $OctopusURL = "https://deploy.quarterspot.net"
                    $OctopusAPIKey =
                    $OctoAPIURL = "$OctopusURL/api/tasks"
                    $MachineName = $env:COMPUTERNAME

                    Set-Location "${env:ProgramFiles}\Octopus Deploy\Tentacle"
                    Add-Type -Path "Newtonsoft.Json.dll"
                    Add-Type -Path "Octopus.Client.dll"

                    $endpoint = new-object Octopus.Client.OctopusServerEndpoint $OctopusURL,$OctopusAPIKey
                    $repository = new-object Octopus.Client.OctopusRepository $endpoint
                    $findMachine = $repository.Machines.FindAll() | where { ($_.name -Match "$MachineName") -and ($_.status -eq "Online")}
                    if ($findMachine.count -eq 1 ){
                        $machineId = $findMachine.Id
                        $OctoMachineName = $findMachine.Name

                        $header = @{ "X-Octopus-ApiKey" = $OctopusAPIKey }

                        $body = @{
                            Name = "UpdateCalamari"
                            Description = "Updating calamari on $MachineName"
                            Arguments = @{
                                Timeout= "00:05:00"
                                MachineIds = @($machineId)
                            }

                        } | ConvertTo-Json

                        Invoke-RestMethod $OctoAPIURL -Method Post -Body $body -Headers $header
                    }else{
                        Break
                    }

				}


				TestScript = {

                    $OctopusURL = "https://deploy.quarterspot.net"
                    $OctopusAPIKey =
                    $OctoAPIURL = "$OctopusURL/api/tasks"
                    $MachineName = $env:COMPUTERNAME

                    Set-Location "${env:ProgramFiles}\Octopus Deploy\Tentacle"
                    Add-Type -Path "Newtonsoft.Json.dll"
                    Add-Type -Path "Octopus.Client.dll"

                    $endpoint = new-object Octopus.Client.OctopusServerEndpoint $OctopusURL,$OctopusAPIKey
                    $repository = new-object Octopus.Client.OctopusRepository $endpoint
                    $findMachine = $repository.Machines.FindAll() | where { ($_.name -Match "$MachineName") -and ($_.status -eq "Online")}
                    start-sleep -seconds 300
                    If ($findMachine.HasLatestCalamari -eq $true ){
                        'Calamari installed'
                        $true
                    }else{
                        'Calamari missing'
                        $false
                    }
				}

				DependsOn = '[Script]ConfigureOctoTentacle'
			}