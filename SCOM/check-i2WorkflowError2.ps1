function new-scomalert {
$evtsource = 'FileMonitoring'
# Register Source if not already registered
if ([System.Diagnostics.EventLog]::SourceExists($evtsource) -eq $false) {
    [System.Diagnostics.EventLog]::CreateEventSource($evtsource, "Application")
}
# Build items for event entry
$evttxt = @"
I2 Workflow Error Starting File Stuck - $($counts.count) Occurrences of stale files 
(older than 5 minutes) found in relation to the i2app. 
This indicates a potential application issue with I2 Workflows.
"@
$evtdat=@{
    Logname = "Application"
    eventID = "8027"
    Source = $evtSource
    Message = $evttxt
    entryType = "Warning"
}
# Write the event entry
write-eventlog @evtdat
}
$Now = Get-Date
$TargetFolder = "\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_df1\Steps", "\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_df2\Steps " ,
"\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_df3\Steps" , "\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_dp\Steps",  
"\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_drp\Steps" , "\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_fp_common\Steps", 
"\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_fp_gifm\Steps", "\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_fp_givm\Steps" ,
"\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_fp_hppm\Steps", "\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_informatica\Swagelok_fp_hppm\Steps" ,
"\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_io1_61\Steps", "\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_io2_61\Steps", 
"\\SCCPROD072\d$\I2_Integration\Wf\Swagelok_scp\Steps" , "\\is1app02\d$\I2_Integration\Wf\Swagelok_dp_comp\Steps", 
"\\is1app02\d$\I2_Integration\Wf\Swagelok_dp_reg\Steps", "\\is1app02\d$\I2_Integration\Wf\Swagelok_io_common\Steps" , 
"\\is1app02\d$\I2_Integration\Wf\Swagelok_io1\Steps", "\\is1app02\d$\I2_Integration\Wf\Swagelok_io2\Steps", 
"\\is1app02\d$\I2_Integration\Wf\Swagelok_io3\Steps" 



$Minutes = "5"
$LastWrite = $Now.AddMinutes(-$Minutes)

##$LastWrite

$Results = get-childitem $TargetFolder *.starting  -Recurse `
    | Where {$_.LastWriteTime -le "$LastWrite" } | Select Fullname ,LastWriteTime, Directory

$Counts= $Results | fl
$Counts.Count
$counts
#Region Prev_Alerting
# if ($Counts.Count -gt 1 )
#{
#$emailFrom = "I2Monitoring@swagelok.com"
#$emailTo = "DBAGroupPager@swagelok.com"
#$subject = "I2 Workflow Error Starting File Stuck"
#$body = $Counts | out-string
#$smtpServer = "smtp.swagelok.com"
#$smtp = new-object Net.Mail.SmtpClient($smtpServer,25)
#$smtp.Send($emailFrom, $emailTo, $subject, $body)
# }
#EndRegion
If ($counts.count -gt 1){
	new-scomalert $counts
} # Finished generating alert where counts greater than 1