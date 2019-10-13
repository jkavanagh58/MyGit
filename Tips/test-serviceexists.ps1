Function test-thisservice{
Param(
	[Parameter(Mandatory=$true,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "Enter Help Message Here")]
	[System.String]$servicename,
		[Parameter(Mandatory=$true,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true,
			HelpMessage = "Enter Help Message Here")]
	[System.String]$servername

)
	$cimsess = New-CimSession -Name CimSession -ComputerName $servername -Credential $admcreds
	$serviceinfo = get-ciminstance -classname Win32_Service -Filter "Name = '$servicename'" -CimSession $cimsess
	Return $serviceinfo
}
$svcinfo = test-thisservice -servername wfm-wintel-02 -servicename "wuauserv"
If ($svcinfo){
    "Service {0} found and is currently {1}" -f $svcinfo.Name, $svcinfo.state
}
Else {
	"Service could not be found"
	$error[0].Exception.Message
}