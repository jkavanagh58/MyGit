<#
.SYNOPSIS
    E-mail Report for BlackOut Sync related tasks
.DESCRIPTION
    This script generates a report on the SCOM BlackOut Sync related scheduled tasks. Script produces an
    HTML report listing the TaskName and it's next run time.
.EXAMPLE
    C:\etc\scripts\report-bblackouttasks.ps1
.OUTPUTS
    SMTP Message
.NOTES
    ===========================================================================
    Created with:	Visual Studio Code
    Created on:		02.19.2018
    Created by:		Kavanagh, John J.
    Organization:	TEKSystems
    Filename:		report-blackouttasks.ps1
    ===========================================================================
    02.19.2018 JJK: DONE: Add sendmail functionality
    02.20.2018 JJK: TODO:Add a custom sort for display
#>
BEGIN {
    Function send-SyncTasksReport {
        param (
            [Parameter(Mandatory = $true,
                ValueFromPipeline = $true,
                Position = 1,
                HelpMessage = "HTML Formatted data")]
            [System.String]$report_data
        )
            $sendmailvals = @{
                To = "john.kavanagh@wegmans.com"
                From = "techadminjxk@wegmans.com"
                Subject = "SCOM Sync Scheduled Tasks for the Month"
                Body        = $report_data
                bodyAsHTML  = $True
                SMTPServer  = "smtp.wegmans.com"
                ErrorAction = "Stop"
            }
            send-mailmessage @sendmailvals
    }
    $report = @()
    # Only used for remote debugging
    $02 = New-CimSession -computername wfm-wintel-02 -Credential $admcreds
#region here-strings for HTML values
$style = @'
<style type="text/css">
h1 {
    background-color: black;
    color:white;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    font-variant-position: super;
    text-align: center
}
table {
	width: 100%;
}
th {
	background-color: darkBlue;
	color: yellow;
}
caption {
    display:table-caption;
    background-color: #f5f5f0;
    font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    font-weight: bold;
    border: 3px solid black;
    border-style: double
}
p {
    font-family:Cambria, Cochin, Georgia, Times, 'Times New Roman', serif;
    font-weight: lighter;
    display:block
}
table, th, td {
	border: 1px solid black;
    border-collapse:collapse
}
tr:nth-child(even) {
    font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif;
    background-color:green;
    color: white
}
tr:nth-child(odd){
    background-color:ivory;
    font-family: 'Franklin Gothic Medium', 'Arial Narrow', Arial, sans-serif
}
</Style>
<title>Production Patching Window Scheduled Tasks</title>
<h1>Production Patching Window Scheduled Tasks</h1>
<p>Report produced to verify scheduled tasks on wfm-wintel-02 that perform the SCCM to SCOM sync for initiating the creation of a Maintenance Window.</p>
'@
$pre = @"
<table><caption>Patching Maintenance Window Scheduled Tasks</caption>
"@
$post = @"
</table><hr>
<p align='center'>Report generated on <i>$((Get-Date).ToString())</i> from $($Env:Computername)</p>
<p align='center'><i>2017 TechWintel $(Get-Date -UFormat '%D %R')</i></p>
"@
#endregion
}
PROCESS {
    $tasks = Get-ScheduledTask -CimSession $02 -TaskName SCOM*
    foreach ($var in $tasks.TaskName){
        $taskInfo = get-scheduledtaskinfo -TaskName $var -CimSession $02
            # Collect data with field names
            $obj = [pscustomobject]@{
                "Task Name" = $taskinfo.TaskName.Normalize()
                "Next Run"  = $taskInfo.nextruntime
            }
        # Add collected data to report array
        $report += $obj
    }
    $convertToHtmlSplat = @{
        Head = $style
        PreContent  = $pre
        PostContent = $post
        As          = 'Table'
    }
    $report | ConvertTo-Html @convertToHtmlSplat | out-file c:\temp\test.html
    invoke-item c:\temp\test.html
}
END {
    get-cimsession $02 | Remove-CimSession
    Remove-Variable -Name pre, post, report, style, tasks, taskinfo
    [System.GC]::Collect()
}