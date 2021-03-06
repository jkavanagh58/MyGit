$srcFile = "E:\Apps\scripts\SCOMisAlive\IamAlive.txt"
$evtSource = 'FileMonitoring'
$evttxt = @"
SCOM Event collection and alerting is functioning.
"@
if (test-path $srcFile){
    #if (((get-date) - (gci $srcFile).CreationTime).TotalHours -gt 8){
        if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
            [System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")
     #   }
        $evtdat=@{
            Logname = "Application"
            eventID = "8030"
            Source = $evtsource
            Message = $evttxt
            entryType = "Information"
        }
        write-eventlog @evtdat
    } 
}

