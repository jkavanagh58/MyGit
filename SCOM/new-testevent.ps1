$evttxt = @"
This is a test message, it is only a test!
"@
$evtSource = 'FileMonitoring'
if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
   [System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")	
}
$evtdat=@{
    Logname="Application"
    eventID="8025"
    Source="FileMonitoring"
    Message = $evttxt
    entryType="Warning"
}
write-eventlog @evtdat