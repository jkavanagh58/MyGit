$srcFile = "E:\COM\Executables\Tours\Logs\status.txt"
$evtSource = 'FileMonitoring'
$evttxt = @"
Tours File Monitoring - The status.txt file in the Tours\Logs folder on
$($env:computername) has existed for more than twenty-eight (28) hours.
This is indicative of an issue with the Tours application.
"@
if (test-path $srcFile){
    if (((get-date) - (gci $srcFile).CreationTime).TotalHours -gt 28){
        if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
            [System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")
        }
        $evtdat=@{
            Logname = "Application"
            eventID = "8003"
            Source = $evtsource
            Message = $evttxt
            entryType = "Warning"
        }
        write-eventlog @evtdat
    } 
}