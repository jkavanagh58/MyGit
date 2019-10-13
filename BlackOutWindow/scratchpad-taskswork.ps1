

[String]$SiteServer = 'wfm-cm12-PS-01'
[String]$ManagementServer = "WFM-OM12-MSM-03.wfm.wegmans.com"
[String]$SiteCode = "P12"
$Report = New-Object System.Collections.ArrayList
Start-OperationsManagerClientShell -ManagementServerName: $ManagementServer -PersistConnection: $true -Interactive: $true
If ($PatchWindow){
	"Querying for {0}" -f $PatchWindow
	$collQuery = @{
		Computername = $siteServer
		NameSpace    = "ROOT\SMS\site_$SiteCode"
		ClassName    = "SMS_Collection"
		Filter       = "Name like 'svr-MW - Production%$PatchWindow%'"
	}
}
Else {
	"Gathering all CCM Groups"
	$collQuery = @{
		Computername = $siteServer
		NameSpace    = "ROOT\SMS\site_$SiteCode"
		ClassName    = "SMS_Collection"
		Filter       = "Name like 'svr-MW - Production -%'"
	}
}
$ccmcollections = Get-CIMInstance @collQuery  | sort-object -Property Name
ForEach ($ccmcoll in $ccmcollections) {
	$SCOMDisplay = "WFM - Windows-" + $ccmcoll.name.trim()
	# Names of tasks do not use comma between hours and minutes
	$schTaskName = $ccmcoll.Name.Replace(":","")
	Try {
		$corrTask = invoke-command -computername $ManagementServer -ScriptBlock {get-scheduledtask -TaskName $using:$schTaskName} -ErrorAction Stop
		$corrTask.State
			$tskInfo = [PSCustomObject]@{
				CCMName     = $ccmcoll.Name
				SCOMDisplay = $SCOMDisplay
				Found       = $True
			}
			$Report.Add($tskInfo) > $null
	}
	Catch {
		"No Task Data"
		$tskInfo = [PSCustomObject]@{
			CCMName     = $ccmcoll.Name
			SCOMDisplay = $SCOMDisplay
			Found       = $False
		}
		$Report.Add($tskInfo) > $null
	}
}
$Report | Export-Excel -Path c:\temp\mmtask.xlsx

<# small scale test #>
$actualtskName = "WFM - Windows-Svr-MW - Production - 3.Wednesday 0600pm-0800pm"
