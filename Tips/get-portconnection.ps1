# Because my creds have not been added to the big masher I can load them from a file
# at PowerShell start
$msmq = New-CimSession -ComputerName "wfm-wintel-02.wfm.wegmans.com" -credential $admcreds
Get-NetTCPConnection -CimSession $msmq -LocalPort 7035