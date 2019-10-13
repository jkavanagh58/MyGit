$scheduler = new-cimsession -computername "wfm-om12-msm-03" -Credential $admcreds
$schedTasks = Get-ScheduledTask -CimSession $scheduler -TaskName "WFM - Windows-Svr-MW*"
ForEach ($task in $schedTasks | sort-object -Property TaskName){
	# $task | Enable-ScheduledTask
	$taskInfo = $task | Get-ScheduledTaskInfo
	"{0} is scheduled to run next {1} and is currently {2}" -f $task.TaskName, $taskInfo.NextRunTime, $task.State
	If ($task.State -eq "Disabled"){
		"Enabling"
		Try {
			$task | Enable-ScheduledTask
		}
		Catch {
			"Unable to Enable {0} ScheduedTask" -f $task.TaskName
		}
	}
}
$scheduler.dispose()

# Renewing testing
# Get list of prod patching schedtasks
$tasks = Get-ScheduledTask -ComputerName wfm-om12-msm-03 -Credential $admcreds
ForEach ($schTask in $tasks){
	$schTaskName = $schTask.Name.Replace(":","")
	"{0} translates to {1}" -f $schTask.Name, $schTask.Name.Replace(":","")
}
