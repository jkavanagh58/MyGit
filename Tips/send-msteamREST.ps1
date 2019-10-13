$myURI = "https://outlook.office.com/webhook/8a3864d7-9dee-4ec6-8bd8-19db1cba464f@1318d57f-757b-45b3-b1b0-9b3c3842774f/IncomingWebhook/62ad999534ce482ca45b39c54162bb0b/66880d15-4bd5-469e-b487-cc8c289d34b9"
$testmsg = @"
This is a simple test
using a here-string to expand the message posting
This sample code can be found at:
http://tinyurl.com/y7yaga5a
"@
$body = ConvertTo-JSON -Depth 2 @{
    title = 'Scripted Post'
    text = $testmsg
}
Invoke-RestMethod -uri $myURI -Method Post -body $body -ContentType 'application/json'