Function write-appevent {
Param
(
    [parameter(Position=0)]
        [String[]]
        $evttxt,
    [parameter(Position=1)]
        [String[]]
        $evtID
)
$evtSource = 'FileMonitoring'
if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
    	[System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")	
}
$evtdat=@{
    Logname 	= "Application"
    EventID 	= $evtID
    Source 		= $evtsource
    Message 	= $evttxt
    EntryType 	= "Warning"
}
write-eventlog @evtdat
} # End of general function to write entry in Application Log

Function get-crtcout {
$evtID='8015'
$outFolder = "U:\CRTC\OutBound"
# Scan folder and sub-folders for files larger than 10MB
$filecol = Get-ChildItem $outFolder -recurse | ? {!($_.PSIsContainer) -and ($_.Length / 1Mb) -gt 10}
	if ($filecol){
$evttxt = @"
CRTC Outbound File Monitoring - File monitoring on $($env:computername)
shows $($filecol.count) file(s) that exceed the ten (10) megabyte 
threshold exist in the $($outFolder) folder including subfolders.
"@
	# Pass event information to function that will write to eventlog
	write-appevent $evtext $evtID
	} # End of if statement testing for data returned by gci
} # End of crtcout function

Function get-swageout {
$evtID='8017'
$outFolder = "U:\Swagelink\OutFilesToDists\CrFiles"
# Scan outFolder folder for files larger than 10MB
$filecol = Get-ChildItem $outFolder |
    ? {!($_.PSIsContainer) -and ($_.Length / 1Mb) -gt 10}
	# If gci returns files larger than 10MB	
	if ($filecol){
$evttxt = @"
Swagelink File Out File Monitoring - File monitoring on $($env:computername)
shows $($filecol.count) file(s) that exceed the ten (10) megabyte 
threshold exist in the $($outFolder) folder including subfolders.
"@
	# Pass event information to function that will write to eventlog
	write-appevent $evtext $evtID
	} # End of if statement testing for data returned by gci
} # End of swageout function

Function get-CRTCTrash {
$evtID='8019'
$outFolder = "U:\CRTC\Trash"
# Scan outFolder folder for files larger than 10MB
$filecol = Get-ChildItem $outFolder |
    ? {!($_.PSIsContainer) -and ($_.Length / 1Mb) -gt 10}
# If gci returns files larger than 10MB	
	if ($filecol){
$evttxt = @"
CRTC Trash File Monitoring - File monitoring on $($env:computername)
shows $($filecol.count) file(s) that exceed the ten (10) megabyte 
threshold exist in the $($outFolder) folder including subfolders.
"@
	# Pass event information to function that will write to eventlog
	write-appevent $evtext $evtID
	} # End of if statement testing for data returned by gci
} # End of CRTCTrash function

## Begin Script
if (get-psdrive u -EA 'SilentlyContinue'){
    # U drive is valid so run FileMon processes
	get-crtcout
    get-swageout
	get-CRTCTrash
}
