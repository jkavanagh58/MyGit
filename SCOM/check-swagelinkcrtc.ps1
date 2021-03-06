Function new-evttext {
Param (
    [parameter(Position=0)]
    [String[]]
    $filecount
)
remove-variable evttxt -EA 'SilentlyContinue'
$script:evttxt = @"
Swagelink CRTC File Monitoring - File monitoring on $($env:computername)
shows $filecount file(s) that exceeds the ten (10) hour threshold exists 
in the $srcFolder folder.
"@

}
if (get-psdrive Y -EA 'SilentlyContinue'){
    $script:srcFolder = "Y:\CRTC_Files\Inbound"
    $filecol = gci $srcFolder -Recurse | ? {!($_.PSIsContainer)}
    if ($filecol.count -ge 10){
        $evtSource = 'FileMonitoring'
        new-evttext $filecol.count
        if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
            	[System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")	
        }
        $evtdat=@{
            Logname 	= "Application"
            EventID 	= "8025"
            Source 		= $evtsource
            Message 	= $script:evttxt
            EntryType 	= "Warning"
        }
        write-eventlog @evtdat
    } # End of if clause for file count
}