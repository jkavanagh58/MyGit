<#
.SYNOPSIS
	Short description
.DESCRIPTION
	Long description
.PARAMETER Path
	Specifies a path to one or more locations.
.PARAMETER LiteralPath
	Specifies a path to one or more locations. Unlike Path, the value of LiteralPath is used exactly as it
	is typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose
	it in single quotation marks. Single quotation marks tell Windows PowerShell not to interpret any
	characters as escape sequences.
.PARAMETER InputObject
	Specifies the object to be processed.  You can also pipe the objects to this command.
.EXAMPLE
	I ♥ PS #>
	Example of how to use this cmdlet
.EXAMPLE
	I ♥ PS #
	Another example of how to use this cmdlet
.INPUTS
	Inputs to this cmdlet (if any)
.OUTPUTS
	Output from this cmdlet (if any)
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		01.31.2018
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		Run-QuickCleanup.ps1
	===========================================================================
	date initials: Enter first comment here
#>
#Requires -RunAsAdministrator
Function get-ccmcachesize {
	# Depending on client install method access to folder might require UAC
	$cacheItems = (Get-ChildItem C:\windows\ccmcache -recurse -force| Measure-Object -property length -sum)
	"{0:N2}" -f ($colItems.sum / 1MB) + " MB"
}
# DISM Cleanup
{(get-windowsfeature).where{$_.installstate -ne 'Installed'} | Remove-WindowsFeature -remove  -whatif}
# Clear CCM Cache
$start = get-ccmcachesize
#Connect to Resource Manager COM Object
$resman = new-object -com "UIResource.UIResourceMgr"
$cacheInfo = $resman.GetCacheInfo()
# Enum Cache elements, compare date, and delete older than 60 days
$cacheinfo.GetCacheElements() |
	where-object {$_.LastReferenceTime -lt (get-date).AddDays(-60)} |
	foreach {$cacheInfo.DeleteCacheElement($_.CacheElementID)}
$end = get-ccmcachesize
# Clear SCOM Agent
