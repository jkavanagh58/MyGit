
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Example uses a document from the recent PowerShell Conference - Europe
$url = "https://github.com/PowerShellConferenceEU/2018/raw/master/Agenda_psconfeu_2018.pdf"
$destination = "$home\agenda.pdf"
Invoke-WebRequest -Uri $url -OutFile $destination -UseBasicParsing
Invoke-Item -Path $destination