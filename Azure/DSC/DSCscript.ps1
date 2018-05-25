Configuration ScriptTest
{
    write-verbose -Message "Starting $MyInvocation.ScriptName " -Verbose
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    $File = 'C:\temp\DSCHelloWorld.txt'
    Node 'localhost' {

        Script MakeDirectories
        {
            GetScript = {
                $gsResult = (Select-String -Path 'C:\temp\DSCHelloWorld.txt' -Pattern 'Hello World!').Matches.Value
                Return @{
                    'Result'= $gsResult
                }
            }

            SetScript = {
                'Hello World!' | Out-File 'C:\temp\DSCHelloWorld.txt';
                Start-Sleep -Seconds (10 * 1)
            }
            TestScript = {
                Write-Verbose $using:File

                $Content = 'Hello World!'
                write-verbose $Content

                If ((Test-path $using:File) -and (Select-String -Path $using:File -Pattern $Content)) {
                    Write-Verbose 'Both File and Content Match'
                    $True
                }
                Else {
                    Write-Verbose 'Either File and/or content do not match'
                    $False
                }

            }
        }
        Script ScriptExample
        {
            SetScript =
            {
                $sw = New-Object System.IO.StreamWriter("C:\Temp\TestFile.txt")
                $sw.WriteLine("Some sample string")
                $sw.Close()
            }
            TestScript = { Test-Path "C:\Temp\TestFile.txt" }
            GetScript = { @{ Result = (Get-Content C:\Temp\TestFile.txt) } }
            DependsOn = '[Script]MakeDirectories'
        }
    }
}