
$invokeWebRequestSplat = @{
    Headers = @{"Accept-Encoding"="gzip, deflate, br"; "Accept-Language"="en-US,en;q=0.9"; "Upgrade-Insecure-Requests"="1"; "User-Agent"="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36"; "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"; "Referer"="https://github.com/jkavanagh58/slackgroup/blob/master/Snippets/vscode/powershell.json"}
    Uri = "https://raw.githubusercontent.com/jkavanagh58/slackgroup/master/Snippets/vscode/powershell.json"
    OutFile = 'c:\temp\another.json'
    UseBasicParsing = $True
}
Invoke-WebRequest @invokeWebRequestSplat



