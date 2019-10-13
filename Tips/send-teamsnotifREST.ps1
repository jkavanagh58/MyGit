# Working with uri string
$uri = "https://outlook.office.com/webhook/8a3864d7-9dee-4ec6-8bd8-19db1cba464f@1318d57f-757b-45b3-b1b0-9b3c3842774f/IncomingWebhook/8c2b1589e2ab45cd8e99f7457b325bfa/66880d15-4bd5-469e-b487-cc8c289d34b9"
# these values would be retrieved from or set by an application
$status = 'Testing'
$fact1 = 'All tests passed'
$fact2 = '1 test failed'
$body = ConvertTo-Json -Depth 4 @{
    title    = '@WindowsEnterpriseArchitecture'
    text     = "Automation Notification - Test"
    sections = @(
        @{
            activityTitle    = 'New Server Report'
            activitySubtitle = 'New Server Report was created $(Get-Date -UFormat "%D %R")'
            activityText     = 'Scheduled task ran $($MyInvocation.MyCommand.Name) '
            activityImage    = 'https://blog.tyang.org/wp-content/uploads/2012/11/Web-Browse-Icons-1.png' # this value would be a path to a nice image you would like to display in notifications
        },
        @{
            title = 'New Server Report'
            facts = @(
                @{
                    name  = 'Script Name'
                    value = "$($MyInvocation.MyCommand.Name)"
                },
                @{
                    name  = 'Host Computer'
                    value = "$($env:COMPUTERNAME) - Please delete"
                }
            )
        }
    )
}
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'


