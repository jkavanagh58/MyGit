
#Requires -Modules VMWare.VimAutomation.Core
BEGIN {
	$Report = @()
	# Connect to VCenter if not already connected
	If (!($defaultviservers)){
		Connect-VIServer rdc-vcsa-01 -Credential $admcreds
	}
}
PROCESS {
	$allVMs = get-view -ViewType VirtualMachine
	ForEach ($VM in $allVMS){
		$vmobj = [pscustomobject]@{
			VMName          = $VM.Name
			"OS Version"    = $VM.Config.GuestFullname
			"Tools Version" = $VM.Config.Tools.ToolsVersion
		}
		$Report += $vmobj
	}
}
END {
	$Report | Sort-Object -Property VMName | Format-Table
}