
function test-QSWEBSite {
    <#
        .Description
           test-QSWEBSite is a basic Status test that sends the result code and measure-command results to Grafana
           Format "websites,WebSite=https://admin.quarterspot.net,instance=source time_ms=3" to send multiple each has to be on a new line
        .Example
            test-QSWEBSite -WebDNSName https://admin.quarterspot.net
            This will test the dns name  the default list of Domain Controllers and send the data to InfluxDB Ping DB
        .Example
            test-QSWEBSite -WebDNSName https://admin.quarterspot.net -test
            This will return what would be sent to influx db
    #>
        [cmdletbinding()]
        param (
            [parameter(ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
            )]
            [string]$URL,
            [parameter(ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
            )]
            $DBURL = "http://c362b671.eastus.cloudapp.azure.com:8086",
            [parameter(ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
            )]
            [string]$DataBase = 'websites',
            [parameter(ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
            )]
            [string]$location,
            [switch]$test
        )


        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12,
            [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Ssl3
            $time = @{}
            $results = @{}
            Write-Verbose $URL
            try{

                # Incapsula issue requires useUnsafeHeaderParsing
                $netAssembly = [Reflection.Assembly]::GetAssembly([System.Net.Configuration.SettingsSection])
                if($netAssembly)
                {
                    $bindingFlags = [Reflection.BindingFlags] "Static,GetProperty,NonPublic"
                    $settingsType = $netAssembly.GetType("System.Net.Configuration.SettingsSectionInternal")

                    $instance = $settingsType.InvokeMember("Section", $bindingFlags, $null, $null, @())

                    if($instance)
                    {
                        $bindingFlags = "NonPublic","Instance"
                        $useUnsafeHeaderParsingField = $settingsType.GetField("useUnsafeHeaderParsing", $bindingFlags)

                        if($useUnsafeHeaderParsingField)
                        {
                          $useUnsafeHeaderParsingField.SetValue($instance, $true)
                        }
                    }
                }
            $time = measure-command { $results = Invoke-WebRequest -Uri $URL -UseBasicParsing -DisableKeepAlive -TimeoutSec 30 -ErrorAction Stop}
            Write-Verbose $results.statuscode
            Write-Verbose $time.TotalSeconds
            }catch{
                $Error[0].Exception.Message
                $time.TotalSeconds = -1
                $results| Add-Member -MemberType NoteProperty -Name stats -Value $false -PassThru -Force | Out-Null
                $results.statuscode = 0
            }
            if ($results.statuscode -eq 200){
                $results | Add-Member -MemberType NoteProperty -Name stats -Value $true -PassThru -Force | Out-Null
            }else{
                $results| Add-Member -MemberType NoteProperty -Name stats -Value $false -PassThru -Force | Out-Null
            }
            $body = ("websites,WebSite="+ $URL +",Location="+ $location +" Stats="+ $results.stats+"`n" +
            "websites,WebSite="+ $URL +",Location="+ $location +" StatusCode="+ $results.statuscode+"`n" +
            "websites,WebSite="+ $URL +",Location="+ $location +" ResponseTime="+ $time.TotalSeconds +"`n"
            )
            Write-Verbose $body
    if ($test){$body}else{
        (Invoke-WebRequest -Uri "$DBURL/write?db=$DataBase" -Method Post -Body ($body)).statuscode
    }

}

$websites = ((Invoke-WebRequest -Uri https://qsinfstorage.blob.core.windows.net/websites/websites.json).content) | ConvertFrom-Json

do {
Start-Sleep -Seconds 30
foreach ($website in $websites.website){
test-QSWEBSite -URL $website -location "TX" -Verbose
    }
    }until(
    (Get-Date) -eq ((Get-Date).AddMinutes(2))
    )