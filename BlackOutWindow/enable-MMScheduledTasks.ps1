<#
.SYNOPSIS
	Enables the scheduled tasks on WFM-OM12-MSM-03 to schedule the Patching related MaintenanceMode Windows.
.DESCRIPTION
	Enables the scheduled tasks on WFM-OM12-MSM-03 to schedule the Patching related MaintenanceMode Windows.
.EXAMPLE
	I ♥ PS >_.\enable-MMScheduledTasks.ps1
	Example of how to use this cmdlet
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
	10.16.2017 JJK:	This script is deprecated with Version two.
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
Param(
	$logFile = "c:\jobs\SCOM\MaintenanceMode\BlackOutScheduledTasks.log"
)
BEGIN {
	$scheduler = new-cimsession -computername "wfm-om12-msm-03" -Credential $admcreds
	$schedTasks = Get-ScheduledTask -CimSession $scheduler -TaskName "WFM - Windows-Svr-MW*"
}
PROCESS {
	ForEach ($task in $schedTasks | sort-object -Property TaskName){
		switch ($task.state) {
			"Enabled" 	{
							Try{
								$task | Disable-ScheduledTask
								$task | Enable-ScheduledTask
							}
							Catch {
								"{0} Unable to Reset {1} ScheduedTask" -f (Get-Date -UFormat '%x-%X'), $task.TaskName | out-file -Path $logFile -Append
							}
						}
			Default 	{
							Try{
								$task | Enable-ScheduledTask
							}
							Catch {
								"{0} Unable to Reset {1} ScheduedTask" -f (Get-Date -UFormat '%x-%X'), $task.TaskName | out-file -Path $logFile -Append
							}
						}
		}
	}
}
End{
	$scheduler.dispose()
}