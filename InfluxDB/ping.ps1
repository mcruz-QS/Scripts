
function test-QSDCs {
    <#
        .Description
           test-QSDCs is a basic Ping test that sends the results to Grafana
           Format "Ping,host=mac,instance=source time_ms=3" to send multiple each has to be on a new line
        .Example
            test-QSDCs
            This will ping the default list of Domain Controllers and send the data to InfluxDB Ping DB
        .Example
            test-QSDCS -hostNames @('HostName', 'etc') -uri 'http://c362b671.eastus.cloudapp.azure.com:8086' -DB 'Ping'
            -hostNames - can change the list of hostNames or read from a file to get the list
            -uri Provide a new location for the influxDB
            -DataBase Provide a new DataBase Name if you want to reuse this for another item

    #>
        [cmdletbinding()]
        param (
            [parameter(ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
            )]
            [string[]]$hostNames =  @("QSVMUEDC01","QSVA-DC01","AUS-DC01","QSVMUEDCADC01","QSNY-DC02"),
            [parameter(ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
            )]
            $uri = "http://c362b671.eastus.cloudapp.azure.com:8086",
            [parameter(ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
            )]
            [string]$DataBase = 'Ping'
        )



    $job = Test-Connection -AsJob $hostNames -Count 1
    $i = 0
    do {start-sleep -seconds 5; $i ++}until ( (($job | get-job).State -eq 'Completed') -or ($i -eq 6))
    $results = $job | Get-Job  | Receive-job

    $body = foreach ($result in $results ){
        if ($null -eq $result.responsetime){
            $ms = -1
        }else {$ms = $result.responsetime}
        ("Ping,host=" + $result.Address +" time_ms=" + $ms +"`n" )
    }

    (Invoke-WebRequest -Uri "$uri/write?db=$DataBase" -Method Post -Body ($body)).statuscode

    }
    $i = 0
    do {
    test-QSDCs;
    $i ++;
    Start-Sleep -Seconds 60
    }until($i -eq 2)