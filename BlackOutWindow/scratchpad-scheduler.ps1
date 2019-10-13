

$OpsMgr = New-Pssession -computername "WFM-OM12-MSM-01.wfm.wegmans.com" -Credential $admcreds -Name OpsMgr -Authentication Kerberos
Invoke-Command -Session $OpsMgr -ScriptBlock { Start-OperationsManagerClientShell -ManagementServerName: "wfm-om12-msm-01.wfm.wegmans.com" -PersistConnection: $true -Interactive: $true } | out-Null
$scomgroups = Invoke-Command -Session $OpsMgr -ScriptBlock {get-scomgroup -DisplayName "WFM - Windows-SVR-*" | Select DisplayName}
$dowpattern = '(Mo(n(day)?)?|Tu(e(sday)?)?|We(d(nesday)?)?|Th(u(rsday)?)?|Fr(i(day)?)?|Sa(t(urday)?)?|Su(n(day)?)?)'
$startpattern = 'day [0-1][0-9]:[0-5][0-9](a|p)m'
$endpattern = '-[0-1][0-9]:[0-5][0-9](a|p)m'
# Window Start
ForEach ($grp in $scomgroups | Sort-Object -Property DisplayName){
	# Window date
	"-" * 56
	$grp.DisplayName -match $dowpattern | out-null
	$MMDOW =  $matches[0]
	# Window start time and duration
	$grp.DisplayName -match $startpattern | out-null
	$MMStart = Get-date($matches[0].Trim("day "))
	# Window End
	try {
		$grp.DisplayName.trim() -match $endpattern | out-null
		$MMEnd = Get-Date($matches[0].Trim("-"))
	}
	Catch {
		"`tCheck {0} for end time" -f $grp.DisplayName
		"`tMessage:{0}" -f $Error[0].Exception.Message
	}
	# TODO: deal with windows that span days ...
	Try {
		If ($MMEnd -lt $MMStart){
			$MMEnd = $MMEnd.AddDays(1)
			"Window for {0}" -f $grp.DisplayName
			"Will Schedule on the next {0}" -f $MMDOW
			"Check for spanning days"
			"Starts {0} and Ends {1} for a total of {2} minutes" -f $MMStart, $MMEnd, ($MMEnd - $MMStart).TotalMinutes
		}
		Else {
			"Window for {0}" -f $grp.DisplayName
			"Will Schedule on the next {0}" -f $MMDOW
			"Starts {0} and Ends {1} for a total of {2} minutes" -f $MMStart, $MMEnd, ($MMEnd - $MMStart).TotalMinutes
		}
	}
	Catch {
		"`tCheck {0} unable to determine end" -f $grp.DisplayName
		"`tMessage:{0}" -f $Error[0].Exception.Message
	}
	#$mmDuration = (Get-Date($MMStart)) - (Get-Date($MMEnd))
	# "{0} will Start at {1}" -f $grp.DisplayName, $MMStart
}

