Function send-teamsnotification {
<#
    .SYNOPSIS
        Simple function to be added for sending process notifications to a teams channel
    .EXAMPLE
        send-teamsnotification -msgBody "This process completed" -color Red
        Simple example
    .NOTES
        ===========================================================================
        Created with:	Visual Studio Code
        Created on:		05.16.2019
        Created by:		Kavanagh, John J.
        Organization:	TEKSystems
        ===========================================================================
        05.16.2019 JJK: TODO Provide valid set for colors.
        05.16.2019 JJK: TODO Add reference to code that this message was generatated from.
#>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory=$True, ValueFromPipeline=$True,
                HelpMessage = "Text to be posted to Teams Channel")]
        [System.String]$msgBody,
        [parameter(Mandatory = $False, ValueFromPipeline = $True,
            HelpMessage = "Incoming Webhook for Teams Test")]
        [System.String]$msgChannel = "https://outlook.office.com/webhook/8a3864d7-9dee-4ec6-8bd8-19db1cba464f@1318d57f-757b-45b3-b1b0-9b3c3842774f/IncomingWebhook/8c2b1589e2ab45cd8e99f7457b325bfa/66880d15-4bd5-469e-b487-cc8c289d34b9",
        [parameter(Mandatory = $False, ValueFromPipeline = $False,
            HelpMessage = "Record DateTime value as String")]
        [System.String]$msgTimestamp,
        [parameter(Mandatory = $False, ValueFromPipeline = $True,
            HelpMessage = "Accent Color for posted message")]
        [System.String]$msgColor = "Orange",
        [parameter(Mandatory = $False, ValueFromPipeline = $True,
            HelpMessage = "Title of Message Post")]
        [System.String]$msgTitle = "Post generated in Scheduled Task on $env:COMPUTERNAME",
        [parameter(Mandatory = $False, ValueFromPipeline = $True,
            HelpMessage = "Summary stats for posted message")]
        [System.String]$msgSummary = "$env:USERNAME from $env:COMPUTERNAME"
    )
    BEGIN {
        $msgtimestamp = Get-Date -UFormat "%D %R"
$msgTxt = @"
$($msgBody)
Message Info: $($msgTimestamp) Submitted using Team function
"@
    }
    PROCESS {
        $sendteamsmessageSplat = @{
            MessageText    = $msgTxt
            Uri            = $msgChannel
            MessageTitle   = $msgTitle
            Color          = $msgColor
            MessageSummary = $msgSummary
        }
        send-teamsmessage @sendteamsmessageSplat
    }
    END {

    }
}