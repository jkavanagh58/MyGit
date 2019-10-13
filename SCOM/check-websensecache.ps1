$evtSource = 'FileMonitoring'
# Register event source if necessary
if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
    [System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")
}
$evttxt = @"
Websense - The Websense cache folder currently has more than 10 files
this has been identified as a potential issue and the status of Websense
should be verified.
"@
# Determine if alert is warranted
if ((gci "D:\APPS\Websense\bin\Cache").Count -gt 10){
    # Generate alert

}