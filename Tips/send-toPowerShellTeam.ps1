#Requires -Modules PSTeams
# Install-Module -Name PSTeams -Scope AllUsers -Confirm:$false -Verbose -Force
$PowerShellChannel = "https://outlook.office.com/webhook/8a3864d7-9dee-4ec6-8bd8-19db1cba464f@1318d57f-757b-45b3-b1b0-9b3c3842774f/IncomingWebhook/e1083536039f45e2a85a580e79294874/66880d15-4bd5-469e-b487-cc8c289d34b9"
$sendteamsmessageSplat = @{
    MessageText    = "You could include something useful here"
    Uri            = $PowerShellChannel
    MessageTitle   = "Sample CLI to Teams Channel"
    Color          = "BurlyWood"
    MessageSummary = "$env:USERNAME from $env:COMPUTERNAME"
}
send-teamsmessage @sendteamsmessageSplat -verbose