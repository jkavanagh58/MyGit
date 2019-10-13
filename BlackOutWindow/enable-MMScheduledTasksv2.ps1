<#
.SYNOPSIS
	Enables the scheduled tasks on WFM-OM12-MSM-03 to schedule the Patching related MaintenanceMode Windows.
.DESCRIPTION
	Enables the scheduled tasks on WFM-OM12-MSM-03 to schedule the Patching related MaintenanceMode Windows.
.PARAMETER logFile
	Full path for logging output for Catch statements. Assumes running on wfm-wintel-02.
.PARAMETER Enable
	If script is called with this Parameter the script will perform the process to Enable the Scheduled Task
.PARAMETER Disable
	If script is called with this Parameter the script will perform the process to Disable the Scheduled Task
.EXAMPLE
	I ♥ PS >_.\enable-MMScheduledTasks.ps1 -Enable
	Example of how to use this script to Enable the scheduled tasks
.EXAMPLE
	I ♥ PS >_.\enable-MMScheduledTasks.ps1 -Disable
	Example of how to use this script to Disable the scheduled tasks
.INPUTS
	None
.OUTPUTS
	None
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		09.15.2017
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		enable-MMScheduledTasks.ps1
	===========================================================================
	09.15.2017 JJK:	TODO: Add WhatIf Support
	09.15.2017 JJK:	Added if loop to enable task if currently disabled
	09.15.2017 JJK:	DONE: Expand If look, if task is enabled, disable and then enable.
	09.15.2017 JJK:	DONE: Convert If/Else to Switch statement
	09.18.2017 JJK:	Cleaned up unnecessary calls for scheduledtask information
	09.18.2017 JJK:	DONE: Create Enable Disable to switch to allow tasks to be enabled or disabled
					from same script
	09.18.2017 JJK:	FIXME: Need to work on verify NextRunTime to ensure enabling does not change based on action
	09.25.2017 JJK:	Fixed syntax issue with Enable and Disable cmdlet call
	09.25.2017 JJK: TODO: work on scheduled task query syntax so it can be run against the day that just sync'ed
	09.25.2017 JJK: Added Switch statement for handling formatting a workable string for searching ScheduledTasks
					by name.
	10.16.2017 JJK:	Added CimSession to Scheduled tasks interaction.
	10.16.2017 JJK:	Debugging with enhanced logging
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
Param(
	$logFile = "c:\jobs\SCOM\MaintenanceMode\BlackOutScheduledTasks.log",
	[Parameter(ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "Day of patching for Scheduled Tasks")]
	[String]$taskDay,
	[Parameter(ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "TaskName from Scheduled Tasks")]
	[String]$nameoftask,
	[Switch]$Enable,
	[Switch]$Disable
)
Begin {
	# Access scheduled task objects via WinRM
	$scheduler = new-cimsession -computername "wfm-om12-msm-03" -Credential $admcreds
	Switch ($taskDay) {
		"Monday"	{$nameoftask = "WFM - Windows-Svr-MW - Production - 1.Monday*"}
		"Tuesday"	{$nameoftask = "WFM - Windows-Svr-MW - Production - 2.Tuesday*"}
		"Wednesday"	{$nameoftask = "WFM - Windows-Svr-MW - Production - 3.Wednesday*"}
		"Thursday"	{$nameoftask = "WFM - Windows-Svr-MW - Production - 4.Thursday*"}
		"Friday"	{$nameoftask = "WFM - Windows-Svr-MW - Production - 5.Friday*"}
	}
	$schedTasks = Get-ScheduledTask -CimSession $scheduler -TaskName "WFM - Windows-Svr-MW*"
}
Process {
	If ($Enable){
		ForEach ($task in $schedtasks | Where State -ne "Ready"){
			Try {
				Enable-ScheduledTask -CimSession $scheduler -TaskName $task.TaskName -Force
				"{0} Enabled {1} ScheduedTask" -f (Get-Date -UFormat '%x-%X'), $task.TaskName | out-file -Path $logFile -Append
			}
			Catch {
				# Log successful Scheduled Task interaction
				"{0} Unable to Reset {1} ScheduedTask" -f (Get-Date -UFormat '%x-%X'), $task.TaskName | out-file -Path $logFile -Append
			}
		}
	}
	If ($Disable){
		ForEach ($task in $schedtasks | Where State -ne "Disabled"){
			Try {
				Disable-ScheduledTask -CimSession $scheduler -TaskName $task.TaskName -Force
				"{0} Disabled for purpose of enabling {1} ScheduedTask" -f (Get-Date -UFormat '%x-%X'), $task.TaskName | out-file -Path $logFile -Append
				Enable-ScheduledTask -CimSession $scheduler -TaskName $task.TaskName -Force
				"{0} Enabled {1} ScheduedTask" -f (Get-Date -UFormat '%x-%X'), $task.TaskName | out-file -Path $logFile -Append
			}
			Catch {
				"{0} Unable to Reset {1} ScheduedTask" -f (Get-Date -UFormat '%x-%X'), $task.TaskName | out-file -Path $logFile -Append
			}
		}
	}
}
End {
	$scheduler.dispose()
	Remove-Variable -Name logfile, task, schedtasks
	[System.GC]::Collect()
}