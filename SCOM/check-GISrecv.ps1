Function check-fmsource ($evtsource) {
# If Application eventlog does not have FileMonitoring registered as
# a source.
if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
    [System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")
}
} # End of check-fmsource
# Variables
$srcFile = "w:\dataalliance\monitor-recv\LAST_CR_RECV.txt"
$evtSource = 'FileMonitoring'
$evttxt = @"
GIS RECV - The LAST_CR_RECV.txt file on $($env:computername)
is older than (30) minutes. This is indicative of an issue with the 
GIS RECV process.
"@
if (get-psdrive W -ea 'SilentlyContinue'){
    # Check for file if W: drive is local - active node
    if (((get-date) - (gci $srcFile).LastWriteTime).TotalMinutes -gt 30){
        check-fmsource $evtsource
        $evtdat=@{
            Logname = "Application"
            EventID = "8007"
            Source = $evtsource
            Message = $evttxt
            EntryType = "Warning"
        }
        write-eventlog @evtdat
    }
}
