<#
	.SYNOPSIS
		Enable the scheduled task to create new MM Window
	.DESCRIPTION
		Function to be run with each SCCM Group sync. Uses the SCOM group name to find the corresponding
		Scheduled Task. This will enable the scheduled task (disable and then enable if the task shows as enabled).
	.PARAMETER groupName
		Uses the SCOM group name which matches with the Scheduled Task Name
	.PARAMETER logFile
		Name of file used to record Scheduled Task interaction.
	.EXAMPLE
		enable-mmtask -groupname $SCOMGroup.FullName
		Example of how to use this function
	.NOTES
		===========================================================================
		Created with:	Visual Studio Code
		Created on:		10.06.2017
		Created by:		Kavanagh, John J.
		Organization:	TEKSystems
		Filename:		function-enableMMTask.ps1
		===========================================================================
		10.06.2017 JJK:	DONE: Work with State Enum for efficiently
		10:06.2017 JJK:	TODO: Add error handling for the enable/disable processes within ScriptBlock
		10:06.2017 JJK:	TODO: Add logging for activities.
		10.06.2017 JJK:	DONE: Create scriptblocks for Query, Enable and Disable
		10.09.2017 JJK: Formalized select-object statement in sbQuery
		10.16.2017 JJK: DONE: Added logging for Scheduled Task operation
		10.24.2017 JJK: Modified out-file replaced -Path with -FilePath
		10.24.2017 JJK: Fixed: issue with providing TaskName to log entry
		11.09.2017 JJK:	Tested scheduled tasks on MSM-03 successfully.
		11.09.2017 JJK:	NOTE: Remove before moving into production
		11.13.2017 JJK:	Convert SCOM Group Name to corresponding scheduled Tasks
		11.13.2017 JJK:	Validated after adding to scratch and running.
#>
Function enable-MMTask {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$false,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true,
			HelpMessage = "SCOM Group Name used to match Scheduled Task Name.")]
		[String]$groupName,
		[String]$logFile = "c:\jobs\SCOM\MaintenanceMode\BlackOutScheduledTasks.log"
	)
	begin {
		# Define all necessary script blocks
		$sbQuery = {
			Param($grpName)
			get-scheduledtask -TaskName $grpName | Select-Object -Property TaskName, State
		}
		$sbEnable = {
			Param($taskName)
				enable-scheduledTask -TaskName $taskName
		}
		$sbDisable = {
			Param($taskName)
				disable-scheduledTask -TaskName $taskName
		}
	}
	process {
		Try {
			$groupName = $groupName.Replace(":","")
			"Querying for {0}" -f $groupName
			$schTask = invoke-command -ScriptBlock $sbquery -Computername "SCOMMgmtServer" -ArgumentList $groupName
			Switch ($schTask.State){
				1 		{
							# Process if current state is Disabled
							"Enable the task"
							$enableTask = invoke-command -ScriptBlock $sbEnable -Computername "SCOMMgmtServer" -ArgumentList $groupName
							"{0} Enabled {1} ScheduedTask" -f (Get-Date -UFormat '%x-%X'), $schTask.TaskName | out-file -FilePath $logFile -Append
						}
				3		{
							# Process if current state is Enabled
							"Need to disable and then enable task"
							$disableTask = invoke-command -ScriptBlock $sbDisable -Computername "SCOMMgmtServer" -ArgumentList $groupName
							"{0} Disabled {1} ScheduedTask" -f (Get-Date -UFormat '%x-%X'), $schTask.TaskName | out-file -FilePath $logFile -Append
							$enableTask = invoke-command -ScriptBlock $sbEnable -Computername "SCOMMgmtServer" -ArgumentList $groupName
							"{0} Enabled {1} ScheduedTask" -f (Get-Date -UFormat '%x-%X'), $schTask.TaskName | out-file -FilePath $logFile -Append
						}
				Default {
							"Need to investigate the current status {0}" -f $schTask.State.ToString()
						}
			}
		}
		Catch {
			"No corresponding tasks found"
		}
	}
	end {
		# Return $schTask
	}
}