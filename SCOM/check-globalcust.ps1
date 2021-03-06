$evtSource = 'FileMonitoring'
$folder =  "E:\COM\Executables\GlobalCustomer\Import"
$evttxt = @"
GlobalCust File Monitoring - A file in the import folder is older than four (4) hours
old.  This is indicative of an issue with the GlobalCust application.
"@
# Get list of files that have existed for longer that 4 hours
$files=gci $folder | ? {((get-date)-$_.CreationTime).TotalHours -gt 4 -and !($_.PSIsContainer)}
If ($files){
    if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
        [System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")
    }
    # Build parameter set for eventlog entry
    $evtdat=@{
        Logname = "Application"
        eventID = "8001"
        Source = $evtSource
        Message = $evttxt
        entryType = "Warning"
    }
    write-eventlog @evtdat
}