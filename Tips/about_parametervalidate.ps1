
# Section demonstrates how to use Parameter validation using Regex or dataset
[CmdletBinding()]
Param(
	[Parameter(Mandatory = $true,
		ValueFromPipeline = $true,
		HelpMessage = "Enter Help Message Here")]
		[ValidatePattern('(Mo(n(day)?)?|Tu(e(sday)?)?|We(d(nesday)?)?|Th(u(rsday)?)?|Fr(i(day)?)?|Sa(t(urday)?)?|Su(n(day)?)?)')]
	[System.String]$DOWPattern,
	[Parameter(Mandatory = $true,
		ValueFromPipeline = $true,
		HelpMessage = "Enter Help Message Here")]
		[ValidateSet("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday")]
	[System.String]$DOWSet
)
$DOWPattern
$DOWSet

# Section to demonstrate how to use EditorServicesCommandSuite
# module is loaded and lets use it... press ctrl+Shift+c once you select
# following line
$gwmiSplat = @{
	Class      = 'win32_computersystem'
	Credential = $admcreds
}
gwmi @gwmiSplat