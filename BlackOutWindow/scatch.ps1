[CmdletBinding()]
Param (
	[parameter(Mandatory=$False, ValueFromPipeline=$True,
			HelpMessage = "Name of server hosting Scheduled Tasks")]
	[String]$taskServer = "WFM-OM12-MSM-03.wfm.wegmans.com"
)
$groupName = "WFM - Windows-Svr-MW - Production - 2.Tuesday 11:30pm-01:00am"
$schedTaskName = $groupName.Replace(":","")
$sbEnable = {
	Param($schedtaskName)
		enable-scheduledTask -TaskName $using:schedtaskName
}
Try {
	$actionItems = Invoke-Command -Computer $taskServer -ScriptBlock $sbEnable -Credential $admcreds
}
Catch {
	$error[0].Exception.Message
	# Send email notification if unable to query tasks
}
$actionitems


<# 
Code to be removed
	$sbQuery = {
		Param($schedtaskName)
		get-scheduledtask -TaskName $using:schedTaskName | Select-Object -Property TaskName, State
	}
	$sbEnable = {
		Param($schedtaskName)
			enable-scheduledTask -TaskName $using:schedtaskName
	}
#>