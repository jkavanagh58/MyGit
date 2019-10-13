if (![Environment]::Is64BitProcess){
$test =@"
    get-childitem -Path C:\etc\scripts
    'complete'
    get-location
"@
    & "$env:WINDIR\sysWow64\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -Command $test
}
Else {
	"Already 32bit mode"
    get-childitem -Path C:\etc\scripts
    [Environment]::Is64BitProcess
}