$url = "http://www.dotnet-lexikon.de/grafik/Lexikon/Windowspowershell.png"
$destination = "$home\powershell.png"

Invoke-WebRequest -Uri $url -OutFile $destination -UseBasicParsing
Invoke-Item -Path $destination