## This is just to set up the env for MongoDB
mkdir mongodb/drivers
NuGet.exe install MongoDB.Driver -version 2.6.1
($dlls | select fullname) -match "net45" | foreach {$_.fullname;Add-Type -Path $_.fullName}