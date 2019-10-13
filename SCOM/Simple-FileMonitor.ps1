$file="E:\Apps\endeca_data\swagelok_config\swagelok_en\data\dgraphs\Dgraph\dgraph_input\swagelok.text"
$evtSource = 'FileMonitoring'
# Register event source if necessary
if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
    [System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")
}
if (((get-date) - (gci $file).LastWriteTime).TotalHours -gt 24){
# Form the message to be include in the eventlog entry
$evttxt = @"
Endeca - It has been determined that swagelok.text has not been updated in over twenty four (24)
hours.  This indicates a potential application issue with Endeca.
$file
"@
# Build items for event entry
$evtdat=@{
    Logname="Application"
    eventID="8001"
    Source=$evtSource
    Message = $evttxt
    entryType="Warning"
}
# Write the eventlog entry
write-eventlog @evtdat
}