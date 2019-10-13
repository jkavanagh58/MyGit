$counter=0
$files="E:\Apps\endeca_data\swagelok_config\swagelok_cn\data\dgraphs\Dgraph\dgraph_input\swagelok.text",
"E:\Apps\endeca_data\swagelok_config\swagelok_de\data\dgraphs\Dgraph\dgraph_input\swagelok.text",
"E:\Apps\endeca_data\swagelok_config\swagelok_en\data\dgraphs\Dgraph\dgraph_input\swagelok.text",
"E:\Apps\endeca_data\swagelok_config\swagelok_es\data\dgraphs\Dgraph\dgraph_input\swagelok.text",
"E:\Apps\endeca_data\swagelok_config\swagelok_fr\data\dgraphs\Dgraph\dgraph_input\swagelok.text",
"E:\Apps\endeca_data\swagelok_config\swagelok_jp\data\dgraphs\Dgraph\dgraph_input\swagelok.text",
"E:\Apps\endeca_data\swagelok_config\swagelok_ru\data\dgraphs\Dgraph\dgraph_input\swagelok.text"
$evtSource = 'FileMonitoring'
ForEach ($file in $files){
	if (((get-date) - (gci $file).LastWriteTime).TotalHours -gt 24){$counter=$counter+1}
}
If ($counter -gt 0){
$evttxt = @"
Endeca - It has been determined that swagelok.text ($($counter) instances) has not been updated in 
over twenty four (24) hours. This indicates a potential application issue with Endeca.
"@
# Register event source if necessary
if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
    [System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")
}
# Build items for event entry
$evtdat=@{
    Logname="Application"
    eventID="8001"
    Source=$evtSource
    Message = $evttxt
    entryType="Warning"
}
# Write the event entry
write-eventlog @evtdat
}