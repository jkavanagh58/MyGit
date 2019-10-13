Function add-scommaintgroup {
[CmdletBinding()]
[OutputType()]
Param(
	[String]$ManagementServer = "WFM-OM12-MSD-02.wfm.wegmans.com",
	[Parameter (Mandatory=$true,
		ValueFromPipelineByPropertyName=$true)]
	[ValidateScript({get-scomgroup -Name "*Production*day*}")]
	[String]$GroupName
)

Begin{}
Process{"Just Testing"}

}