<#
.SYNOPSIS
	Build a new techie USB Stick
.DESCRIPTION
	This script will take a USB stick and create all of the folders and files you may
	use in your day to day troubleshooting
.PARAMETER Path
	Specifies a path to one or more locations.
.PARAMETER LiteralPath
	Specifies a path to one or more locations. Unlike Path, the value of LiteralPath is used exactly as it
	is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose
	it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
	characters as escape sequences.
.PARAMETER InputObject
	Specifies the object to be processed.  You can also pipe the objects to this command.
.EXAMPLE
	C:\PS>
	Example of how to use this cmdlet
.EXAMPLE
	C:\PS>
	Another example of how to use this cmdlet
.INPUTS
	Inputs to this cmdlet (if any)
.OUTPUTS
	Output from this cmdlet (if any)
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		08.07.2018
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		Format-NewUSB.ps1
	===========================================================================
	Version 1.0
		08.07.2018 JJK: Create basic script
		08.07.2018 JJK: Yes I am using Region sections but only because some of you won't stop using
						the ISE
		08.07.2018 JJK: TODO: Add GParted
		08.07.2018 JJK: TODO: Add sysinternals. If not installed locally install on machine and then
						copy files to USB
#>
[CmdletBinding()]
Param (
	[System.Object]$usbDrives
)
BEGIN {
	If ($usbDrives = get-ciminstance -query "Select * From win32_logicaldisk Where DriveType = 2") {
		If ($usbDrives.Count -gt 1){
			#Need to deal with multiples....
			EXIT
		}
	}
	Else {
		Write-Error "You need a USB drive"
		Start-Sleep -Seconds 5
		EXIT
	}
	$etcFldrs = New-Object System.Collections.ArrayList
	# Populate the array with folder names
	$etcFldrs.Add("Scripts") | Out-Null
	$etcFldrs.Add("Tools") | out-null
	$etcFldrs.Add("Plaster") | out-null
	$toolFldrs = New-Object System.Collections.ArrayList
	# Populate the array with folder names
	$toolFldrs.Add("ISOs") | Out-Null
	$toolFldrs.Add("Tools") | out-null
	$toolFldrs.Add("Diagnostics") | out-null
}
PROCESS {
#Region Folders
	ForEach ($fldr in $etcFldrs){
		Try {
			$etcPath = Join-Path $USBDrives[0].DeviceID -ChildPath "\etc"
			# Remember no need to test-path because the new-item will create the lower level folder(s)
			New-Item -Name $fldr -Path $etcPath -ItemType Directory | out-null
		}
		Catch {
			# Need build out some specific catch terms but for now
			Write-Error "Unable to create the folder named $($fldr)"
			$Error[0].Exception.Message
		}
	}
	"etc folder structure built"
	ForEach ($fldr in $toolFldrs){
		Try {
			$toolsPath = Join-Path $USBDrives[0].DeviceID -ChildPath "\Tools"
			# Remember no need to test-path because the new-item will create the lower level folder(s)
			New-Item -Name $fldr -Path $toolsPath -ItemType Directory | out-null
		}
		Catch {
			# Need build out some specific catch terms but for now
			Write-Error "Unable to create the folder named $($fldr)"
			$Error[0].Exception.Message
		}
	}
	"Tools folder structure built"
#endregion
#Region sysinternals
# Move on nothing to see here
#endregion
#Region Departed
	# Needs some code to grab the latest version
	"Downloading GParted Live ISO"
	$gpartURL = "https://downloads.sourceforge.net/gparted/gparted-live-0.31.0-1-i686.iso"
	$destination = "$toolsPath\ISOs\gparted-live-0.31.0-1-i686.iso"
	Invoke-WebRequest -Uri $gparturl -OutFile $destination -UseBasicParsing
#endregion
}
END {
	Remove-Variable -Name usbDrives, etcFldrs, toolFldrs, gpartURL
	[System.GC]::Collect()
}
