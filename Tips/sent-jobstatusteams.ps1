Function send-vchecknotification {
    [CmdletBinding()]
Param (
    [parameter(Mandatory=$False, ValueFromPipeline=$True,
        HelpMessage = "Status")]
    [System.String]$postType = "Success",
    [parameter(Mandatory=$True, ValueFromPipeline=$True,
        HelpMessage = "Url to the WintelJobs Incoming Webhook")]
    [System.String]$postUrl = "https://outlook.office.com/webhook/8a3864d7-9dee-4ec6-8bd8-19db1cba464f@1318d57f-757b-45b3-b1b0-9b3c3842774f/IncomingWebhook/944cb4ce423e4346a6128be311d97488/66880d15-4bd5-469e-b487-cc8c289d34b9",
    [parameter(Mandatory=$True, ValueFromPipeline=$False,
        HelpMessage = "Date String for Dynamic value in WebRequest Action")]
    [System.String]$postTimestamp = (Get-Date -Format "MM.dd.yyyy")
)
BEGIN {
# Text that will be posted to Teams Channel
# Sadly here-strings can't be indented
$msgTxt = @"
The most recent version of the VCheck report can
be found on $env:COMPUTERNAME
"@

}
PROCESS {

}
END {
    Remove-Variable -Name postType
    [System.GC]::Collect()

}
}