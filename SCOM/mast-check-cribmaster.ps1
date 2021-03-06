﻿$evtSource = 'FileMonitoring'
# Define location to be used
set-location "D:\apps\cribmast\data\update"
# Get list of files that have been open for longer that 20 minutes
$files=gci  | ? {((get-date)-$_.LastWriteTime).TotalMinutes -gt 20 -and !($_.PSIsContainer)}
# If any files are returned older than 20 minutes send alert via email
$evttxt = @"
A local process has identified that there is a file or files in the Cribmaster processing folder that is older than twenty (20)
minutes.  This is normally associated with a Cribmaster application issue.
Please verify Cribmaster is operating on IS1CRB01.
"@
If ($files){
   # Files have existed for more than twenty minutes in cribmaster
   if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
        [System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")
    }
   $evtdat=@{
    Logname = "Application"
    eventID = "8000"
    Source = $evtsource
    Message = $evttxt
    entryType = "Warning"
   }
   write-eventlog @evtdat
   # replace with SMTP Message
   $MailMessage = @{ 
        To = "#SwgISRunItSupport@swagelok.com","#SwgISRunItLAN@swagelok.com" 
        From = "#ISNotification@swagelok.com"
        Subject = "Cribmaster" 
        Body = "Files have existed for more than twenty minutes in cribmaster UPDATE folder. Check is1crb01" 
        Smtpserver = "smtp.swagelok.com" 
        ErrorAction = "SilentlyContinue" 
    } 
    #send-mailmessage @MailMessage
}
