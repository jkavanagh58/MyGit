$evttxt = @"
SCOM is Alive page sent.
"@
$evtSource = 'FileMonitoring'
if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
   [System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")	
}
$evtdat=@{
    Logname="Application"
    eventID="8031"
    Source="FileMonitoring"
    Message = $evttxt
    entryType="Information"
}
write-eventlog @evtdat