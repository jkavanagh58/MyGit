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
		Filename:		enable-MMTask.ps1
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
		11.09.2017 JJK:	NOTE: Remove -credential $admcreds before moving into production
		11.13.2017 JJK:	Convert SCOM Group Name to corresponding scheduled Tasks
		11.13.2017 JJK:	Validated after adding to scratch and running.
		05.24.2018 JJK: FIXME: Invoke-Commands in Switch statement need to be re-worked.
		05.24.2018 JJK: FIXME: teardown scriptblocks and validate variable names
		05.28.2018 JJK:	Changed task name from grpName to schedTaskName
		05.30.2018 JJK:	Verified log file
		05.30.2018 JJK: TODO:Add log where missing
		05.30.2018 JJK: Added verbose message
		06.03.2018 JJK:	Variablized name of scheduled task server
		06.03.2018 JJK:	TODO:Tasks for email notification on failures
#>
Function Enable-MMTask {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$true,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true,
			HelpMessage = "SCOM Group Name used to match Scheduled Task Name.")]
		[String]$groupName,
		[string]$taskServer = "WFM-OM12-MSM-03.wfm.wegmans.com",
		[Parameter(Mandatory=$false,
			HelpMessage = "Path for function logging")]
		[String]$logFile = "c:\jobs\SCOM\MaintenanceMode\BlackOutScheduledTasks.log",
		[String]$logTimeStamp = (Get-Date -UFormat '%d%H%MR%b%y')
	)
	BEGIN {
		$logactivitySplat = @{
			entryType  = "Information"
			logMessage = "Processing $($GroupName)"
			logFile    = $logFile
		}
		log-activity @logactivitySplat
	}
	PROCESS {
		Write-Verbose -Message "[PROCESS]Converting from SCOM Group to Schedule Task name"
		# Scheduled Task name do not use colons for time format
		$schedTaskName = $groupName.Replace(":","")
		"Querying for {0}" -f $schedTaskName
		$schTask = invoke-command -ScriptBlock {get-scheduledtask -TaskName $using:schedTaskName | Select-Object -Property TaskName, State} -Computername $taskServer
		IF ($schTask) {
			Try {
				Write-Verbose -Message "[PROCESS]Scheduled Task Found"
				Invoke-Command -ComputerName $taskServer -ScriptBlock {enable-scheduledTask -TaskName $using:schedtaskName}
			}
			Catch {
				Write-Error -Message "[PROCESS]Failed to enable $($schedtaskname)"
				$logactivitySplat = @{
					entryType  = "Error"
					logMessage = "Unable to enable $($schedTaskName)"
					logFile    = $logFile
				}
				log-activity @logactivitySplat
			}
		}
		Else {
			Write-Verbose -Message "[PROCESS]Unable to find scheduled task"
			$logactivitySplat = @{
				entryType  = "Information"
				logMessage = "No Corresponding tasks found for $($schedTaskName)"
				logFile    = $logFile
			}
			log-activity @logactivitySplat
		}
	}
	END {
		# Update the schdTask variable
		$schTask = invoke-command -ScriptBlock {get-scheduledtask -TaskName $using:schedTaskName | Select-Object -Property TaskName, State} -Computername $taskServer 
		$schTask | out-file -FilePath $logFile -Append
		$logactivitySplat = @{
			entryType  = "Information"
			logMessage = "$($schedTaskName)"
			logFile    = $logFile
		}
		log-activity @logactivitySplat
	}
}
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
		Created on:		05.31.2018
		Created by:		Kavanagh, John J.
		Organization:	TEKSystems
		Filename:		Disable-MMTasks.ps1
		===========================================================================
		05.31.2018 JJK:	Function started
		05.31.2018 JJK:	Leaving Saturday and Sunday in ValidateSet for PatchWindow in case patching windows are added.
		06.06.2018 JJK:	TODO: Notification\Error Handling for disable process
#>
Function Disable-MMTasks {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$false,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true,
			HelpMessage = "Enter Day of Patching for MM Tasks to be processed")]
		[ValidateSet("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")]
		[String]$PatchWindow,
		[String]$taskServer = "WFM-OM12-MSM-03.wfm.wegmans.com",
		[Parameter(Mandatory=$false,
			HelpMessage = "Path for function logging")]
		[String]$logFile = "c:\jobs\SCOM\MaintenanceMode\BlackOutScheduledTasks.log",
		[String]$logTimeStamp = (Get-Date -UFormat '%d%H%MR%b%y')
	)
	BEGIN {

	}
	PROCESS {
		If (!$PatchWindow) {
			Write-Verbose -Message "[PROCESS]This will run against all"
			$invokecommandSplat = @{
				ComputerName = $taskServer
				ScriptBlock  = { get-ScheduledTask -TaskPath \ -TaskName "*Production*" | Disable-ScheduledTask }
			}
			$schedTasks = Invoke-command @invokecommandSplat
			ForEach ($schedTask in $schedTasks){
				"{0}: Task {1} is {2}" -f $logTimeStamp, $schedTask.TaskName, $schedTask.State | out-file -FilePath $logFile -Append
			}
		}
		Else {
			Switch ($PatchWindow) {
				"Monday"	{
								Write-Verbose -Message "[PROCESS]Will disable Monday Tasks"
								$invokecommandSplat = @{
								    ComputerName = $taskServer
								    ScriptBlock  = {get-ScheduledTask -TaskPath \ -TaskName "WFM - Windows-Svr-MW - Production - 1.$usingPatchWindow*" | Disable-ScheduledTask }
								}
								$schedTasks = Invoke-command @invokecommandSplat
								ForEach ($schedTask in $schedTasks){
									"{0}: Task {1} is {2}" -f $logTimeStamp, $schedTask.TaskName, $schedTask.Statee
								}
							}
				"Tuesday"	{
								Write-Verbose -Message "[PROCESS]Will disable Tuesday Tasks"
								$invokecommandSplat = @{
								    ComputerName = $taskServer
								    ScriptBlock  = {get-ScheduledTask -TaskPath \ -TaskName "WFM - Windows-Svr-MW - Production - 2.$usingPatchWindow*" | Disable-ScheduledTask }
								}
								$schedTasks = Invoke-command @invokecommandSplat
								ForEach ($schedTask in $schedTasks){
									$task.state
								}
							}
				"Wednesday"	{
								Write-Verbose -Message "[PROCESS]Will disable Wednesday Tasks"
								$invokecommandSplat = @{
								    ComputerName = $taskServer
								    ScriptBlock  = {get-ScheduledTask -TaskPath \ -TaskName "WFM - Windows-Svr-MW - Production - 3.$usingPatchWindow*" |  Disable-ScheduledTask }
								}
								$schedTasks = Invoke-command @invokecommandSplat
								ForEach ($schedTask in $schedTasks){
									"{0}: Task {1} is {2}" -f $logTimeStamp, $schedTask.TaskName, $schedTask.State
								}
							}
				"Thursday"	{
								Write-Verbose -Message "[PROCESS]Will disable Thursday Tasks"
								$invokecommandSplat = @{
								    ComputerName = $taskServer
								    ScriptBlock  = {get-ScheduledTask -TaskPath \ -TaskName "WFM - Windows-Svr-MW - Production - 4.$usingPatchWindow*" | Disable-ScheduledTask }
								}
								$schedTasks = Invoke-command @invokecommandSplat
								ForEach ($schedTask in $schedTasks){
									"{0}: Task {1} is {2}" -f $logTimeStamp, $schedTask.TaskName, $schedTask.State
								}
							}
				"Friday"	{
								Write-Verbose -Message "[PROCESS]Will disable Friday Tasks"
								$invokecommandSplat = @{
								    ComputerName = $taskServer
								    ScriptBlock  = {get-ScheduledTask -TaskPath \ -TaskName "WFM - Windows-Svr-MW - Production - 5.$usingPatchWindow*" | Disable-ScheduledTask }
								}
								$schedTasks = Invoke-command @invokecommandSplat
								ForEach ($schedTask in $schedTasks){
									"{0}: Task {1} is {2}" -f $logTimeStamp, $schedTask.TaskName, $schedTask.State
								}
							}
			}
		}
	}
	END {

	}
}
Function log-activity {
	[CmdletBinding()]
	Param (
		[parameter(Mandatory=$False, ValueFromPipeline=$True,
				HelpMessage = "Date of Log Entry")]
		[DateTime]$logDateFormat = (get-date -format g),
		[parameter(Mandatory=$False, ValueFromPipeline=$True,
				HelpMessage = "Name of logfile")]
		[System.String]$logFile,
		[parameter(Mandatory=$True, ValueFromPipeline=$True,
				HelpMessage = "Classify Entry")]
		[ValidateSet("Information","Error","Success")]
		[System.String]$entryType,
		[parameter(Mandatory=$True, ValueFromPipeline=$True,
				HelpMessage = "Log Message")]
		[System.String]$logMessage
	)
	BEGIN {
		if (!(Test-Path $logFile)) {
			Write-Verbose -Message "[LOGFUNCTION]If file does not exist create."
			New-Item $logFile -ItemType File -Force
		}
	}
	PROCESS {
		"{0}: {1} - {2}" -f $logDateFormat, $entryType, $logMessage | out-file -FilePath $logFile -Append
	}
}
