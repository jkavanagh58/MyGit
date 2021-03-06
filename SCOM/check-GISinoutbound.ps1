function check-inbound {
$evtSource = 'FileMonitoring'
$evttxt = @"
GIS Inbound - A file on $($env:computername) Inbound folder exceeds
the 10 (10) megabytes threshold. This is indicative of an issue with the 
GIS application processing.
"@
$inFolder = "W:\DataAlliance\InBound\"
$filecol = Get-ChildItem $inFolder |
    ? {!($_.PSIsContainer) -and ($_.Length / 1Mb) -gt 10} |
    Select-Object Name, CreationTime,Length,  @{Name="Mbytes";Expression={$_.Length / 1Mb}} 
if ($filecol){
	if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
    	[System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")	
	}
	$evtdat=@{
            Logname = "Application"
            EventID = "8011"
            Source = $evtsource
            Message = $evttxt
            EntryType = "Warning"
        }
    write-eventlog @evtdat
}
} # End inbound function
function check-outbound {
$evtSource='FileMonitoring'
$evttxt = @"
GIS Outbound - A file on $($env:computername) Outbound folder exceeds
the ten (10) megabytes threshold. This is indicative of an issue with the 
GIS application processing.
"@
$outFolder = "W:\DataAlliance\Outbound\"
$filecol = Get-ChildItem $outFolder |
    ? {!($_.PSIsContainer) -and ($_.Length / 1Mb) -gt 10} |
    Select-Object Name, CreationTime,Length,  @{Name="Mbytes";Expression={$_.Length / 1Mb}} 
if ($filecol){
	if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
    	[System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")	
	}
	$evtdat=@{
            Logname = "Application"
            EventID = "8013"
            Source = $evtsource
            Message = $evttxt
            EntryType = "Warning"
        }
    write-eventlog @evtdat
}
} # End outbound function
if (get-psdrive W){
    # W drive found, run FileMon on active node
	check-inbound	# Run function to look for inbound files
	check-outbound	# Run function to look for outbound files
}
