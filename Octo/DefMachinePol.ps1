<#

#>

$freeDiskSpaceThreshold = 5GB

Try {
	Get-WmiObject win32_LogicalDisk -ErrorAction Stop  | ? { ($_.DriveType -eq 3) -and ($_.FreeSpace -ne $null)} |  % { CheckDriveCapacity @{Name =$_.DeviceId; FreeSpace=$_.FreeSpace} }

	$servicesOk=(get-service qs* | select-object name,status,starttype | where starttype -eq Automatic | where-object status -ne running | measure-object | select-object -ExpandProperty count ) -lt 1
	if($servicesOK -ne $true){
	    write-warning "Some Services with Automatic Startup are not Running"
	}
} Catch [System.Runtime.InteropServices.COMException] {
	Get-WmiObject win32_Volume | ? { ($_.DriveType -eq 3) -and ($_.FreeSpace -ne $null) -and ($_.DriveLetter -ne $null)} | % { CheckDriveCapacity @{Name =$_.DriveLetter; FreeSpace=$_.FreeSpace} }
	Get-WmiObject Win32_MappedLogicalDisk | ? { ($_.FreeSpace -ne $null) -and ($_.DeviceId -ne $null)} | % { CheckDriveCapacity @{Name =$_.DeviceId; FreeSpace=$_.FreeSpace} }
}