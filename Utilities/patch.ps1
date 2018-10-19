$HotFix = Get-HotFix | where { ($_.HotFixId -eq 'KB4338815') -or ($_.HotFixId -eq 'KB4338831')  } |
    select-object PSComputerName, HotFixID, InstalledOn, Description, Caption

if ($HotFix.HotFixId -ne 'KB4338831' ){

    if (!(test-path c:\temp\msu)){
        mkdir c:\temp\msu
    }
    $uri = 'http://download.windowsupdate.com/d/msdownload/update/software/updt/2018/07/windows8.1-kb4338831-x64_c5f105fa1349fa534f19035aa8a0796985c6be58.msu'
    $File = "c:\temp\msu\kb4338831.msu"
    Invoke-WebRequest -Uri $uri -Method Get -OutFile $File
    wusa.exe $File /quiet /forcerestart /log:"c:\temp\msu\kb4338831.log"

    Get-HotFix | select-object PSComputerName, HotFixID, InstalledOn, Description, Caption |
        where { ($_.HotFixId -eq 'KB4338815') -or ($_.HotFixId -eq 'KB4338831')  }
}else{
    $HotFix
}