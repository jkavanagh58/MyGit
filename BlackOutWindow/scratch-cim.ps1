[CmdletBinding()]
Param(
	[Parameter(Mandatory=$false,
		HelpMessage = "CFGMGR Server")]
	[String]$SiteServer = 'wfm-cm12-PS-01',
	[Parameter(Mandatory=$false,
		HelpMessage = "OPSMGR Server")]
	[String]$ManagementServer = "WFM-OM12-MSM-03.wfm.wegmans.com",
	[Parameter(Mandatory=$false,
		HelpMessage = "CFGMGR Site Code")]
	[String]$SiteCode = "P12",
	[Parameter(Mandatory=$false,
		HelpMessage = "Log file for script transactions")]
	[String]$LogFile = "C:\Jobs\SCOM\MaintenanceMode\Sync.txt",
	[Parameter(Mandatory=$false,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		HelpMessage = "Enter Day of Patching to be processed")]
		[ValidateSet("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")]
	[String]$PatchWindow
)
BEGIN {
	$cimSess = New-CimSession -ComputerName $siteServer -Credential $admcreds
	If ($PatchWindow){
		"Querying for {0}" -f $PatchWindow
		$collQuery = @{
			CImSession = $cimSess
			NameSpace    = "ROOT\SMS\site_$SiteCode"
			ClassName    = "SMS_Collection"
			Filter       = "Name like 'svr-MW - Production%$PatchWindow%'"
		}
	}
	Else {
		"Gathering all CCM Groups"
		$collQuery = @{
			CImSession = $cimSess
			NameSpace    = "ROOT\SMS\site_$SiteCode"
			ClassName    = "SMS_Collection"
			Filter       = "Name like 'svr-MW - Production -%'"
		}
	}
	$ccmcollections = Get-CIMInstance @collQuery | sort-object -Property Name
}
PROCESS {
	ForEach ($ccmColl in $ccmcollections) {
		# Retrieve members of collection - pass parameter to Get-WMIObject
		$mbrqry = @{
			CImSession = $cimSess
			Namespace  = "ROOT\SMS\site_$SiteCode"
			Query      = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($ccmColl.CollectionID)' order by name"
		}
		$SMSMembers = Get-CIMInstance @mbrqry 
		$SMSMembers.Count

		# ===== WMI
		$mbrqry = @{
			ComputerName = $SiteServer
			Namespace    = "ROOT\SMS\site_$SiteCode"
			Query        = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($ccmColl.CollectionID)' order by name"
	}
		$WMISMSMembers = Get-WmiObject @mbrqry
		$WMISMSMembers.Count
	}
}