


$testwebhook = "https://outlook.office.com/webhook/8a3864d7-9dee-4ec6-8bd8-19db1cba464f@1318d57f-757b-45b3-b1b0-9b3c3842774f/IncomingWebhook/8c2b1589e2ab45cd8e99f7457b325bfa/66880d15-4bd5-469e-b487-cc8c289d34b9"


$BodyTemplate = @"
    {
        "@type": "MessageCard",
        "@context": "https://schema.org/extensions",
        "summary": "ADUserLockOut-Notification",
        "themeColor": "D778D7",
        "title": "Test Code",
         "sections": [
            {
            
                "facts": [
                    {
                        "name": "Username:",
                        "value": "DOMAIN_USERNAME"
                    },
                    {
                        "name": "Time:",
                        "value": "DATETIME"
                    }
                ],
                "text": "An AD account is currently being locked out for 15 minutes"
            }
        ]
    }
"@
    if (Search-ADAccount -LockedOut){
        foreach ($user in (Search-ADAccount -LockedOut)){
            $body = $BodyTemplate.Replace("DOMAIN_USERNAME","$user").Replace("DATETIME",$(Get-Date))
            Invoke-RestMethod -uri $Testwebhook -Method Post -body $body -ContentType 'application/json'
        }
    }
    # Using PSTeams
    $sendTeamsMessageSplat = @{
        Color = 'DarkBlue'
        MessageText = "Testing using a third party module"
        URI = $testwebhook
        MessageTitle = "Programmatic"
    }

    <#
        Hello World 
    #>