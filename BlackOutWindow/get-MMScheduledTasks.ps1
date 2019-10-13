[CmdletBinding()]
Param(
	[parameter(Mandatory=$False, ValueFromPipeline=$True,
			HelpMessage = "Day of Week to list")]
		[ValidateSet("Monday","Tuesday","Wednesday","Thursday","Friday", IgnoreCase)]
	[String]$DOWReport,
	[parameter(Mandatory=$False, ValueFromPipeline=$False,
			HelpMessage = "Scheduled Task Base Query")]
	[String]$taskName = "WFM - Windows-Svr-MW - Production*" 
)
BEGIN {
	$schedTasks = New-Object System.Collections.ArrayList
	$msm03 = new-cimsession -ComputerName wfm-om12-MSM-03 -Credential $admcreds
	# Change base query if Operator input
	If ($DOWReport) {
		$taskName = "WFM - Windows-Svr-MW - Production*$DOWReport*"
	}
}
PROCESS {
	$allTasks = get-scheduledtask -CimSession $msm03 -TaskPath "\" -TaskName $taskName |
		select-object -Property TaskName, State 
	# Process results
	$allTasks | Foreach-Object {
		$obj = [PSCustomObject]@{
			TaskName       = $_.TaskName
			StateofService = $_.State
			LastChecked    = (Get-Date)
		}
		$schedTasks.Add($obj) | out-null
	}
	$schedTasks
}
END {
	$msm03 | Remove-CimSession
}