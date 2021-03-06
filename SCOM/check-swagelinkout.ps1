Function new-scomalert {
Param(
	[Boolean]$fcount,
	$numfiles,
	$srcfolder
)
# Cant be indented
if ($fcount){
$evttxt = @"
Swagelink File Out Heartbeat File Monitoring - File monitoring on 
$($env:computername) shows $($numfiles) file(s) which exceeds
the one hundred (100) count threshold exists in the $($srcFolder) folder.
"@
}
Else {
$evttxt = @"
Swagelink File Out Heartbeat File Monitoring - File monitoring on 
$($env:computername) shows that file(s) that exceed the two (2) hour 
threshold exist in the $($srcFolder) folder.
"@
}
    # Event Log Source, create if not already registered
	$evtSource = 'FileMonitoring'
    if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
        	[System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")	
    }
    $evtdat=@{
        Logname 	= "Application"
        EventID 	= "8021"
        Source 		= $evtsource
        Message 	= $evttxt
        EntryType 	= "Warning"
		Category 	= 0
    }
    write-eventlog @evtdat
} # End of new-scomalert
# Only continue of drive X: is available
if (get-psdrive x -EA 'SilentlyContinue'){
$srcFolder = "x:\Swagelink\OutFilesToDists\Heartbeat"
$filecol = Get-ChildItem $srcFolder | Where-Object {!($_.PSIsContainer) }
if ($filecol){
	# Write eventlog entry if gci returns 100 objects or more
	if ($filecol.count -ge 100){
		$fcount=$true
		$numfiles=$filecol.count
		new-scomalert $fcount $numfiles $srcFolder
	}
	Else {
		$fileage = $filecol | Where-Object {((Get-Date)-($_.LastWriteTime)).TotalHours -gt 2}
		if ($fileage){
			$fcount=$false
			$numfiles = $fileage.count
			new-scomalert $fcount $numfiles $srcFolder
		}
	}
} # End of filecol interrogation
} # End of psdrive check