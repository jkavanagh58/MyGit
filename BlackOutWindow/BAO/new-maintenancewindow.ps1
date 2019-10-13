<#
	.SYNOPSIS
		Process to place server(s) in maintenance mode
	.DESCRIPTION
		Process will allow for creating and extending a maintenance window in OpsMgr
	.PARAMETER Server
		Computer to be placed into MaintenanceMode
	.PARAMETER StartStopMM
		Value to initiate a start or stop OpsMgr maintenance window.
	.PARAMETER MMTime
		Length of minutes for the Maintenance Window (Maximum 1440)
	.PARAMETER MMReason
		List of specified allowed values provided
	.PARAMETER MMComment
		String that can be used to further document why the maintenance window is being created
	.PARAMETER omServer
		String representing the Operations Manager Management Server to use.
	.LINK https://docs.microsoft.com/en-us/powershell/module/operationsmanager/start-scommaintenancemode?view=systemcenter-ps-2016
		Start-SCOMMaintenanceMode cmdlet documentation
	.LINK https://docs.microsoft.com/en-us/powershell/module/operationsmanager/get-scomagent?view=systemcenter-ps-2016
		Get-SCOMAgent documentation
	.LINK https://blogs.technet.microsoft.com/kevinjustin/2017/08/24/scom-maintenance-mode-powershell/
		SCOM Maintenance Mode PowerShell - demonstration of using PowerShell to work with SCOM MaintenanceMode
		Updated 12.11.2018
	.EXAMPLE
		C:\PS> .\new-maintenancewindow.ps1 -ServerName machine.wfm.wegmans.com -WindowTime 15
		Example of how to use this cmdlet
	.EXAMPLE
		"wfm-wintel-01.wfm.wegmans.com","wfm-wintel-02.wfm.wegmans.com" |
			%{C:\etc\scripts\new-maintenancewindow.ps1 -fqdn $_ -MMTime 30 -MMComment "Just testing adhoc" -verbose}
		Example of starting a SCOM Maintenance Window for multiple computers with a custom comment and verbose output
	.OUTPUTS
		[Int32]
	.NOTES
		===========================================================================
		Created with:	Visual Studio Code
		Created on:		11.01.2017
		Created by:		Kavanagh, John J.
		Organization:	TEKSystems
		Filename:		new-maintenancewindow.ps1
		Version:		1.0a
		===========================================================================
		01.03.2018 JJK:	DONE:Find related monitoring objects for entered server
		01.15.2018 JJK: Formalized script parameters
		01.16.2018 JJK: Will circle back for ValidatePattern Regex FQDN
		01.16.2018 JJK: FQDN validation back in. Known issue with VSCode EditorSyntax #26
		01.17.2018 JJK: TODO:Test Get-SCOMMOnitoringObject for single pass or multi-array loops as well
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
		08.22.2018 JJK: DONE: Step into maintenance mode; issue with passing all objects
		08.22.2018 JJK:	DONE: Look at implementing a switch based on object type and current Maintenance Mode state
		08.22.2018 JJK: TODO: Handle non-intelligent calling of script for handling extending MMode as well as ending MMode
		08.22.2018 JJK: DONE: Ensure MMTime stays in an acceptable range
		08.22.2018 JJK:	Removed ValidatePattern for server parameter; not my intent
		08.24.2018 JJK:	DONE:Remove invoke-command and sessions as this will be run locally on a SCOM Management
						server - will wait for testing
		08.24.2018 JJK:	DONE:Use the collection and if process from Rod's original code... struggling
		09.02.2018 JJK: DONE:Change text of automation db entry
		09.26.2018 JJK: TODO:Error Handling for stop action
		10.23.2018 JJK: TODO: Verify the extending of a current window, initial tests indicate only a 5 minute extension
		10.23.2018 JJK:	DONE: Change MMTime variable. Not Mandatory but evaluate if Start is specified. Possible use of dynamic
						parameter
		10.23.2018 JJK:	DONE: Process to extend window is not working
		10.31.2018 JJK: TODO: Test StartMaintenanceMode - Recursive
		10.31.2018 JJK:	DONE: Test StopMaintenanceMode - Recursive
		11.01.2018 JJK:	DONE: Resolve issue with related objects recording as extending versus starting
		11.01.2018 JJK:	Using the current start method is processing recursively
		11.01.2018 JJK:	TODO: Remove Related Objects for Start
		11.01.2018 JJK:	TODO: Verify/Validate Extending existing maintenance window works recursively
		12.10.2018 JJK:	Testing the extend process
		12.14.2018 JJK: TODO: With API method the need for sub-functions should be re-considered.
		12.18.2018 JJK:	Removed Block Commented CMDLet calls
		12.20.2018 JJK:	Code cleanup and review
		12.20.2018 JJK: Code Folding is not collapsing start function correctly
		12.21.2018 JJK:	FIXME: Return from script is including the search results not just RC
#>
[CmdletBinding(SupportsShouldProcess)]
[OutputType([System.Int32],ParameterSetName = "Orchestrator")]
Param(
	[Parameter(Mandatory=$True,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "FQDN of machine to place into maintenance mode")]
		#[ValidatePattern('(?=^.{1,254}$)(^(?:(?!\d+\.|-)[a-zA-Z0-9_\-]{1,63}(?<!-)\.?)+(?:[a-zA-Z]{2,})$)')] # Comment to correct' syntax highlighting
		[Alias("ServerName","FQDN","Servers")]
	[String]$server,
	[Parameter(Mandatory=$true)]
  		[ValidateSet("start","stop")]
  	[String]$StartStopMM,
	[Parameter(ValueFromPipelineByPropertyName=$true,
		Mandatory=$False)]
		[Alias("Minutes","WindowTime")]
	[int32]$MMTime = 15,
	[parameter(Mandatory=$False, ValueFromPipeline=$True,
			HelpMessage = "Operations Manager Server hosting ops")]
	[System.String]$omServer = "wfm-om12-msm-03.wfm.wegmans.com",
	#[System.String]$omServer = "tst-om12-msm-01.test.wfm.local",
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
	[System.String]$MMComment = "BAO Scripted MaintenanceMode window",
	[parameter(Mandatory=$False, ValueFromPipeline=$False,
			HelpMessage = "Static value to handle non-delimited input")]
	[System.String]$delim = ",",
	[parameter(Mandatory=$False, ValueFromPipeline=$False,
		ParameterSetName = "Orchestator",
		HelpMessage = "Return Code 0 for success")]
	[Int32]$RC=0,
	[parameter(Mandatory=$False, ValueFromPipeline=$False,
			HelpMessage = "Job Type Code for AutomationDB")]
	[System.String]$dbJobType = "BAOOpsMgrMaintenanceMode",
	[parameter(Mandatory=$False, ValueFromPipeline=$False,
			HelpMessage = "Appliction for writing to db")]
	[System.String]$dbApp = "Automation"
)
BEGIN {
	Function Start-BAOMaintenanceMode {
	<#
		.SYNOPSIS
				Function will be called if StartStopMM value is Stop
		.OUTPUTS
			[Int32]
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
	[OutputType('System.String')]
		# Function will be called if StartStopMM value is Start
		Param(
			[parameter(Mandatory=$True, ValueFromPipeline=$True,
				HelpMessage = "Server SCOM Agent")]
			$serverObject
		)
		$procStart = [System.Diagnostics.StopWatch]::StartNew()
		Try {
			$opsmgrClass = Get-ScomClass -Name "Microsoft.Windows.Computer"
			$priInstance = get-scomclassinstance -Class $opsmgrClass | Where-Object {$_.DisplayName -eq $serverObject.DisplayName}
			if ($PSCmdlet.ShouldProcess($ServerObject.DisplayName, "Placing into Maintenance Mode")) {
				If ($priInstance.InMaintenanceMode){
					Write-Verbose -Message "[PROCESS]Extending Maintenance Mode"
					# Extend current window by adding entered or default amount of mintutes to current scheduled end time
					# of running maintenance window
					Write-Verbose -Message "[PROCESS]Adding $($MMTime) to existing maintenance window"
					$priInstance.UpdateMaintenanceMode(
						$priInstance.GetMaintenanceWindow().ScheduledEndTime.ToLocalTime().addminutes($MMTime).touniversaltime(),
						$MMReason,
						$MMComment,
						[Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive
					)
					# Recording activity to automation database
					$dbText = "Extending maintenance Window on {0} for {1} minutes" -f $priInstance.DisplayName, $MMTime
					# For readability I use a splat to pass all parameters to the function
					$writeautomationrecSplat = @{
						procAction    = $dbText
						jobType       = $dbJobType
						app           = $dbApp
						jobLocation   = "$($MyInvocation.MyCommand.Name) on $env:computername"
						jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
						jobReturnCode = 0
					}
					# Call the function from new-automationdbentry.ps1 passing all parameters from the splat
					write-automationrec @writeautomationrecSplat
				}
				Else {
					Write-Verbose -Message "[PROCESS]Starting Maintenance Mode"
					$priInstance.ScheduleMaintenanceMode(
						[datetime]::Now.touniversaltime(),
						([datetime]::Now).addminutes($MMTime).touniversaltime(),
     					$mmReason,
     					$mmComment,
      					"Recursive"
      				)
					# Recording activity to automation database
					$dbText = "Creating maintenance Window for {0} for {1} minutes" -f $priInstance.DisplayName, $MMTime
					# For readability I use a splat to pass all parameters to the function
					$writeautomationrecSplat = @{
						procAction    = $dbText
						jobType       = $dbJobType
						app           = $dbApp
						jobLocation   = "$($MyInvocation.MyCommand.Name) on $env:computername"
						jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
						jobReturnCode = 0
					}
					# Call the function from new-automationdbentry.ps1 passing all parameters from the splat
					write-automationrec @writeautomationrecSplat
				}
			}
		}
		Catch {
			$Error[0].Exception.Message
			# Recording activity to automation database
			$dbText = "Unable to perform maintenance Window action for {0}" -f $priInstance.DisplayName
			# For readability I use a splat to pass all parameters to the function
			$writeautomationrecSplat = @{
				procAction    = $dbText
				jobType       = $dbJobType
				app           = $dbApp
				jobLocation   = "$($MyInvocation.MyCommand.Name) on $env:computername"
				jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
				jobReturnCode = 1
			}
			# Call the function from new-automationdbentry.ps1 passing all parameters from the splat
			write-automationrec @writeautomationrecSplat
			# Set return code to 1 to indicate failure
			$RC = 1
		}
	}
	Function Stop-BAOMaintenanceMode {
	<#
		.SYNOPSIS
				Function will be called if StartStopMM value is Stop
		.OUTPUTS
			[Int32]
	#>
		[CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
		[OutputType('System.Int32')]
		Param(
			[parameter(Mandatory=$True, ValueFromPipeline=$True,
				HelpMessage = "Server SCOM Agent")]
			$serverObject
		)
		$procStart = [System.Diagnostics.StopWatch]::StartNew()
		if ($PSCmdlet.ShouldProcess($ServerObject, "Ending Maintenance Mode")) {
			# Stop Action goes here
			Try {
				$opsmgrClass = get-scomclass -name ’Microsoft.Windows.Computer’
				$computer = get-scomclassinstance -Class $opsmgrClass | Where-Object {$_.Name -eq $serverObject.DisplayName}
				$computer.StopMaintenanceMode([DateTime]::Now.ToUniversalTime(),[Microsoft.EnterpriseManagement.Common.TraversalDepth]::Recursive)
				# Recording activity to automation database
				$dbText = "Maintenance Window for {0} stopped" -f $ServerObject.DisplayName
				# For readability I use a splat to pass all parameters to the function
				$writeautomationrecSplat = @{
					procAction    = $dbText
					jobType       = $dbJobType
					app           = $dbApp
					jobLocation   = "$($MyInvocation.MyCommand.Name) on $env:computername"
					jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
					jobReturnCode = 0
				}
				# Call the function from new-automationdbentry.ps1 passing all parameters from the splat
				write-automationrec @writeautomationrecSplat
			}
			Catch {
				# Recording activity to automation database
				$dbText = "Unable to Stop MaintenanceMode for {0}. Error: {1}" -f $serverObject.DisplayName, $Error[0].Exception.Message
				# For readability I use a splat to pass all parameters to the function
				$writeautomationrecSplat = @{
					procAction    = $dbText
					jobType       = $dbJobType
					app           = $dbApp
					jobLocation   = "$($MyInvocation.MyCommand.Name) on $env:computername"
					jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
					jobReturnCode = 1
				}
				# Call the function from new-automationdbentry.ps1 passing all parameters from the splat
				write-automationrec @writeautomationrecSplat
				$RC = 1
				$Error[0].Exception.Message
			}
		}
	}
	If (($StartStopMM -eq "Start") -and ($MMTime -eq $null)){
		Write-Error -Message "You must enter a number of minutes for this process" -ErrorAction Stop
		Exit
	}
	Switch ($server){
		{$PSItem.contains(" ")} {$servers = $server.split(" ")}
		{$PSItem.contains(",")} {$servers = $server.split(",")}
		Default	{$servers = $server}
	}
	# Load database function into memory
	Try {
        # . "\\wfm.wegmans.com\Departments\InformationTechnology\TechWintel\.Scripts\Automation\new-automationdbentry.ps1"
        # Moved to local due to ExecutionPolicy
        . "D:\Scripts\System\new-automationdbentry.ps1"
	}
	Catch {
		# Write Log entry
		"{0}: {1} was unable to load the automation database function, please check execution policy" -f (Get-Date -UFormat '%x-%X'), $myinvocation.MyCommand.Name |
			Out-File c:\temp\automation.log -Append
	}
	#135841 - Move Timer process to functions
	# Establish SCOM Shell connection
	Write-Verbose -Message "[BEGIN]Loading SCOM API"
    $startOperationsManagerClientShellSplat = @{
        PersistConnection    = $true
        Interactive          = $true
        ManagementServerName = $omServer
    }
	Start-OperationsManagerClientShell @startOperationsManagerClientShellSplat | Out-Null
	# Ensure time entered does not exceed 1440 (minutes)
	If ($MMTime -gt 1440){
		$MMTime = 1440
	}
	# Set MM end time
	$MMEnd = (get-Date).AddMinutes($MMTime)
}
PROCESS {
	# $procStart = [System.Diagnostics.StopWatch]::StartNew()
	ForEach ($srv in $servers){
		# Determine if server can be found, if not exit script
		Try {
			Write-Verbose -Message "[BEGIN]Verifying computer exists in OpsMgr"
			$serverObject = get-scomagent -Name ([System.Net.DNS]::GetHostByName($srv).HostName) -ErrorAction Stop
		}
		Catch {
			# "Unable to find agent for {0}" -f $srv
			Write-Error -Message "Unable to find agent for computer requested"
			$dbText = "Unable to find SCOM agent for {0}" -f $srv
			# For readability I use a splat to pass all parameters to the function
			$writeautomationrecSplat = @{
				procAction    = $dbText
				jobType       = $dbJobType
				app           = $dbApp
				jobLocation   = "$($MyInvocation.MyCommand.Name) on $env:computername"
				jobduration   = [Math]::Round($procstart.elapsed.TotalMinutes, 2)
				jobReturnCode = 1
			}
			# Call the function from new-automationdbentry.ps1 passing all parameters from the splat
			write-automationrec @writeautomationrecSplat
			# Set return code to 1 to indicate failure
			$RC = 1
		}
		# Use the startstopmm variable
		switch ($startstopmm) {
			"Start" {
				Start-BAOMaintenanceMode -ServerObject $serverObject
			}
			"Stop" {
				Stop-BAOMaintenanceMode -serverObject $serverObject
			}
		}
	}
}
END {
	Return $RC
	# Script Cleanup
	Write-Verbose -Message "[END]Variable cleanup"
	# Remove variables created during runtime
	Remove-Variable -Name server,omServer, MMTime, MMEnd, MMReason, MMComment, allinstances, priInstance, curMaintMode, agentObjects, procStart, startstopmm -ErrorAction SilentlyContinue
	Write-Verbose -Message "[END]Removing Functions"
	Remove-Item Function:Start-BAOMaintenanceMode, Function:Stop-BAOMaintenanceMode
	# initiate memory garbage collection
	[System.GC]::Collect()
}