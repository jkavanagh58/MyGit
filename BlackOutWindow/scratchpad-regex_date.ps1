<#
# Original method but name and split makes for a complicated solution
$pattern =[regex]'(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)'
$val = "WFM - Windows-Svr-MW - Production - 3.Wednesday 09:00pm-11:00pm Orchestrator"
$i=0
$val.split("-") | ForEach {
	If($_ -match $pattern){
		$i++
		new-variable -Name var$i -Value $matches[0] -Force
	}
}
#>
$pattern =[regex]'(1[012]|[1-9]):[0-5][0-9](\\s)?(?i)(am|pm)'
$val = "WFM - Windows-Svr-MW - Production - 3.Wednesday 09:00pm-11:00pm Orchestrator"
#$test = $pattern.match($val)
$times = select-string -InputObject $val -Pattern $pattern -AllMatches | ForEach {$_.matches} | ForEach{$_.Value}
If ($times.count -ne 2){
	"Unable to continue with {0} times values" -f $times.count
	Break
}
If ($times[0] -gt $times[1]){
	$MMStart = get-Date($times[0])
	$MMEnd = get-date($times[1])
}
Else {
	# Timespan for window spans multiple days
	$MMStart = get-Date($times[0])
	$MMEnd = (get-date($times[1])).AddDays(1)
}

"MaintenanceMode for {0} will start at {1} and end in {2} minutes" -f $val, $MMStart, (new-timespan -Start $mmStart -End $mmend).TotalMinutes
#"MaintenanceMode for {0} will start at {1} and end in {2} minutes" -f $val, $MMStart, ((get-date($MMEnd))-(get-date($MMStart))).TotalMinutes
