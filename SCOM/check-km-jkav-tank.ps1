$srcFile = "E:\COM\Executables\KnowledgeManagement\Logs\status.txt"
$evtSource = 'FileMonitoring'
$evttxt = @"
KnowledgeManagement File Monitoring - The status.txt file in the KnowledgeManagement\Logs folder on
$($env:computername) has existed for more than twenty-eight (28) hours.
This is indicative of an issue with the KnowledgeManagement application.
"@
if (test-path $srcFile){
    if (((get-date) - (gci $srcFile).CreationTime).TotalHours -gt 28){
        if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
            [System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")
        }
        $evtdat=@{
            Logname = "Application"
            eventID = "8005"
            Source = $evtsource
            Message = $evttxt
            entryType = "Warning"
        }
        write-eventlog @evtdat
    } 
}