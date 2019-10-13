<#
.SYNOPSIS
	Short description
.DESCRIPTION
	Long description
.PARAMETER Server
	FQDN of server to be placed into MaintenanceMode
.PARAMETER MMTime
	Length of minutes for the Maintenance Window
.PARAMETER MMReason
	List of specified allowed values provided
.PARAMETER MMComment
	String that can be used to further document why the maintenance window is being created
.PARAMETER omServer
	String representing the Operations Manager Management Server to use.
.EXAMPLE
	C:\PS> .\new-maintenancewindow.ps1 -ServerName machine.wfm.wegmans.com -WindowTime 15
	Example of how to use this cmdlet
.EXAMPLE
	"wfm-wintel-01.wfm.wegmans.com","wfm-wintel-02.wfm.wegmans.com" |
		%{C:\etc\scripts\new-maintenancewindow.ps1 -fqdn $_ -MMTime 30 -MMComment "Just testing adhoc" -verbose}
	Example of starting a SCOM Maintenance Window for multiple computers with a custom comment and verbose output
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		11.01.2017
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		new-maintenancewindow.ps1
	===========================================================================
	01.03.2018 JJK:	DONE:Find related monitoring objects for entered server
	01.15.2018 JJK: Formalized script parameters
	01.16.2018 JJK: Will circle back for ValidatePattern Regex FQDN
	01.16.2018 JJK: FQDN validation back in. Known issue with VSCode EditorSyntax #26
	01.17.2018 JJK: TODO:Test Get-SCOMMOnitoringObject for single pass or multiarray loops as well
	01.18.2018 JJK:	Added MMReason parameter to allow more accurate reporting. Defined ValidateSet as cmdlet only
					takes set acceptable values
	01.18.2018 JJK:	Added: MMComment parameter to allow more explanation as to why the window is being created.
	01.18.2018 JJK:	Added: code to add record to automation database
	08.20.2018 JJK:	Added serverName variable, stripping the FQDN to simple server name only
	08.20.2018 JJK: Updated: streamlined variable used for agent lookup
	08.20.2018 JJK: TODO: Add error handling for Start-SCOMMaintenanceMode
	08.20.2018 JJK:	Fixed get-scomclassinstance; was missing $using reference
	08.20.2018 JJK: Added verbose messaging
	08.20.2018 JJK: TODO: Add omServer variable to param statement
	08.22.2018 JJK:	TODO: Check for maintenance mode
	08.22.2018 JJK: TODO: Step into maintenance mode; issue with passing all objects
	08.22.2018 JJK:	TODO: Look at implementing a switch based on object type and current Maintenance Mode state
	08.22.2018 JJK: TODO: Handle non-intelligent calling of script for handling extending MMode as well as ending MMode
	08.22.2018 JJK: DONE: Ensure MMTime stays in an acceptable range
	08.22.2018 JJK:	Removed ValidatePattern for server parameter; not my intent
	08.24.2018 JJK:	TODO:Remove invoke-command and pssession processes as this will be run locally on a SCOM Management
					server
	08.24.2018 JJK:	TODO:Use the collection and if process from Rod's original code... struggling
#>
[CmdletBinding()]
Param(
	[Parameter(Mandatory=$False,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "FQDN of machine to place into maintenance mode")]
		#[ValidatePattern('(?=^.{1,254}$)(^(?:(?!\d+\.|-)[a-zA-Z0-9_\-]{1,63}(?<!-)\.?)+(?:[a-zA-Z]{2,})$)')] # Comment to correct' syntax highlighting
		[Alias("ServerName","FQDN")]
	[String]$server,
	[Parameter(Mandatory=$true)]
  		[ValidateSet("start","stop")]
  	[String]$StartStopMM,
	[Parameter(ValueFromPipelineByPropertyName=$true,
		Mandatory=$true)]
		[Alias("Minutes","WindowTime")]
	[int32]$MMTime = 15,
	[parameter(Mandatory=$False, ValueFromPipeline=$True,
			HelpMessage = "Operations Manager Server hosting ops")]
	#[System.String]$omServer = "wfm-om12-msm-01.wfm.wegmans.com",
	[System.String]$omServer = "tst-om12-msm-01.test.wfm.local",
	[Parameter(Mandatory = $false, ValueFromPipeline = $true,
		HelpMessage = "Specify reason for the Maintenance Window")]
		[ValidateSet(
			"PlannedOther",
			"UnplannedOther",
			"PlannedHardwareMaintenance",
			"UnplannedHardwareMaintenance",
			"PlannedHardwareInstallation",
			"UnplannedHardwareInstallation",
			"PlannedOperatingSystemReconfiguration",
			"UnplannedOperatingSystemReconfiguration",
			"PlannedApplicationMaintenance",
			"ApplicationInstallation",
			"ApplicationUnresponsive",
			"ApplicationUnstable",
			"SecurityIssue",
			"LossOfNetworkConnectivity"
		)]
	[System.String]$MMReason="PlannedOther",
	[Parameter(Mandatory=$false,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "This is a free form  comment that can be helpful when reporting Maintenance Windows")]
	[System.String]$MMComment = "Scripted MaintenanceMode window"
)
Begin {
	# Load database function into memory
	Write-Verbose -Message "[BEGIN]Connecting to db library"
	Try {
		. "\\wfm.wegmans.com\Departments\InformationTechnology\TechWintel\.Scripts\Automation\new-automationdbentry.ps1"
	}
	Catch {
		Write-Error -Message "Unable to load db library"
		"{0}: {1} was unable to load the automation database function, please check execution policy" -f (Get-Date -UFormat '%x-%X'), $myinvocation.MyCommand.Name |
			Out-File c:\temp\automation.log -Append
	}
	Write-Verbose -Message "[BEGIN]Creating PSSession"
	$bypass = new-pssession -computername $omServer -Credential $newcreds
	$serverFQDN = [System.Net.DNS]::GetHostByName($server).HostName
	# Load the Operations Manager Shell
	Write-Verbose -Message "[BEGIN]Loading SCOM API in Remote Session"
	Invoke-Command -Session $bypass -ScriptBlock {Start-OperationsManagerClientShell -ManagementServerName: $omServer -PersistConnection: $true -Interactive: $true} | out-Null
	# Determine if server can be found, if not exit script
	Try {
		"Searching OpsMan for Server"
		Invoke-Command -Session $bypass -ScriptBlock {$srvObj = get-scomagent -Name $using:serverFQDN -ErrorAction Stop} | out-null
	}
	Catch {
		"Unable to find agent for {0}" -f $server
		Exit
	}
	If ($MMTime -gt 1440){
		$MMTime = 1440
	}
}
Process {
	$procStart = [System.Diagnostics.StopWatch]::StartNew()
	# Set MM end time
	$MMEnd = (get-Date).AddMinutes($MMTime)
	$agtLookup = "*" +  $server.Split(".")[0] + "*"
	Invoke-Command -session $bypass -ScriptBlock {
		Write-Verbose -Message "[PROCESS]Looking for objects named $($agtLookup)"
		$agentObjects = Get-SCOMClassInstance -Name $using:agtLookup
		ForEach ($agentObject in $agentObjects) {
			if ($StartStopMM -like "start"){
				If ($agentObject.InMaintenanceMode){
					# Not sure why this statement exists
					Set-SCOMMaintenanceMode -MaintenanceModeEntry $agentObject -EndTime $endTime -Comment "Reset Maintenance Mode added $Duration Mins. End time now $endTime."
				}
				# Process the SCOM agent before related objects
				ElseIf ($agentObject.InMaintenanceMode -eq $False -and $agentObject.DisplayName -like $Server) {
					Start-SCOMMaintenanceMode -Instance $agentObject -Reason "PlannedOther" -EndTime $endTime -Comment "Scheduled SCOM Maintenance Window" -ErrorAction Continue #-WhatIf
				}
				ElseIf ($agentObject.InMaintenanceMode -eq $False -and $agentObject.DisplayName -notlike $Server){
					Set-SCOMMaintenanceMode -MaintenanceModeEntry $agentObject -EndTime $endTime -Comment "Reset Maintenance Mode added $Duration Mins. End time now $endTime."
				}
				# Previous code
				# Start-SCOMMaintenanceMode -instance $agentObjects -EndTime $using:MMEnd -Comment $using:MMComment -Reason $using:MMReason -WhatIf
			}
			Else {
				# Run Stop operations
			}
		}
	}
	Write-Verbose -Message "[PROCESS]Writing record to Automation database"
	Try {

		$dbText = "{0} placed into MaintenanceMode" -f $server
		# For readability I use a splat to pass all parameters to the function
		$writeautomationrecSplat = @{
			procAction    = $dbText
			jobType       = "ServerMaintenanceMode"
			app           = "Wintel"
			jobLocation   = "Script:{0} on Host:{1}" -f $MyInvocation.MyCommand.Name, $env:computername
			jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
			jobReturnCode = 0
		}
		# Call the function from new-automationdbentry.ps1 passing all parameters from the splat
		write-automationrec @writeautomationrecSplat
	}
	Catch {
		$dbText = "{0} placed into MaintenanceMode" -f $server
		# For readability I use a splat to pass all parameters to the function
		$writeautomationrecSplat = @{
			procAction    = $dbText
			jobType       = "ServerMaintenanceMode"
			app           = "Wintel"
			jobLocation   = "Script:{0} on Host:{1}" -f $MyInvocation.MyCommand.Name, $env:computername
			jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
			jobReturnCode = 1
		}
		# Call the function from new-automationdbentry.ps1 passing all parameters from the splat
		write-automationrec @writeautomationrecSplat
	}
}
End {
	# Script Cleanup
	Write-Verbose -Message "[END]Varibale cleanu"
	# Remove variables created during runtime
	Remove-Variable -Name server,omServer, MMTime, MMEnd, MMReason, MMComment
	Write-Verbose -Message "[END]End remote session"
	# End the remote session
	$bypass | remove-pssession
	Write-Verbose -Message "[BEGIN]Initiate garbage collection"
	# initiate memory garbage collection
	[System.GC]::Collect()
}