Function Send-MsgPoSHChannel {
    #Requires -Modules PSTeams
    # 04.30.2019 JJK:   TODO: Add Available colors to param statement with ValidateSet
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $False, ValueFromPipeline = $True,
            HelpMessage = "MS Teams Webhook to post message to")]
        [System.String]$PowerShellChannel = "https://outlook.office.com/webhook/8a3864d7-9dee-4ec6-8bd8-19db1cba464f@1318d57f-757b-45b3-b1b0-9b3c3842774f/IncomingWebhook/e1083536039f45e2a85a580e79294874/66880d15-4bd5-469e-b487-cc8c289d34b9",
        [parameter(Mandatory = $False, ValueFromPipeline = $False,
            HelpMessage = "Record DateTime value as String")]
        [System.String]$timestamp,
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
        $timestamp = Get-Date -Format "MM.dd.yyyy"
        # No indenting for Here-Strings
        $msgTxt = @"
Why another post from CLI. This is using a module.
`tThis is a cleaner option but requires a module to be installed using
`tPowerShellGet
You can view this code at:
`thttps://wegit.visualstudio.com/_git/ServiceDelivery?path=%2FTips%2Fsend-msteamModule.ps1&version=GBmaster
`t`tUgggh forgot to save the updated webhook config
PSTeams Module required`r
Text Date: $($timestamp)
"@
    }
    PROCESS {
        $sendteamsmessageSplat = @{
            MessageText    = $msgTxt
            Uri            = $PowerShellChannel
            MessageTitle   = $msgTitle
            Color          = $msgColor
            MessageSummary = $msgSummary
        }
        send-teamsmessage @sendteamsmessageSplat -verbose
    }
    END {
        Remove-Variable -Name timestamp, PowerShellChannel, msg*
        [System.GC]::Collect()
    }
}