<#
.SYNOPSIS
	Report on out of date Chocolatey packages
.DESCRIPTION
	Generates a report to console of Chocolatey installed packages that are out of date. Optional feature to be
	included will attempt to use install-package to update the current machine with the latest online version.
.PARAMETER switch
	If specified will attempt to perform an install-package to update package
.EXAMPLE
	C:\PS> .\get-chocoinventory.ps1
	Example of how to use this script
.EXAMPLE
	I ♥ vscode  >_ invoke-command -computer computerA -FilePath c:\etc\scripts\Tips\get-chocoinventory.ps1
	Example of how to run this script against a remote computer using the local script

.LINK https://blogs.technet.microsoft.com/heyscriptingguy/2015/07/29/use-function-to-determine-elevation-of-powershell-console/
	Using Scripting guy function for credibiity.
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		11.27.2017
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		get-chocoinventory.ps1
	===========================================================================
	12.05.2017 JJK: TODO: Test update functionality
	12.05.2017 JJK:	Consider using get-package for confirmation message in Update process
	02.07.2018 JJK: Convert console output to write-output
	02.07.2018 JJK: TODO:Evaluate if there are out of date packages and report if all packages are current
	02.07.2018 JJK: Added memory cleanup
	02.07.2018 JJK: TODO: Test to determine if require elevated can only be applied if Update is used
#>
[CmdletBinding()]
Param(
	[Switch]$update
)
Begin {
	Function Test-IsAdmin {
	<#
	.SYNOPSIS
		Tests if the user is an administrator
	.DESCRIPTION
		Returns true if a user is an administrator, false if the user is not an administrator
	.EXAMPLE
		Test-IsAdmin
	#>
		$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
		$principal = New-Object Security.Principal.WindowsPrincipal $identity
		$principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
	}
}
Process {
	$installed = (get-package -ProviderName Chocolatey).Where{$_.Status -eq "Installed"}
	ForEach ($pkg in $installed ) {
		$online = find-package -Name $pkg.Name -ProviderName Chocolatey
		If ($online.version -gt $pkg.Version) {
			write-output "$($pkg.name) current version $($pkg.version) online version shows $($online.version)"
			If ($Update){
				If (Test-IsAdmin){
					Try {
						Install-Package -Name $pkg.Name -ProviderName Chocolatey -Confirm:$False -Force
						write-output "$($pkg.Name) version $($online.version) successfully installed"
					}
					Catch {
						Write-Output "Unable to install ($pkg.Name) from Chocolatey this is why I have been using Chocolatey"
					}
				}
				Else {
					"You need to run this as Administrator"
				}
			}
		}
	}
}
End {
	Remove-Variable -Name installed, online
	[System.GC]::Collect()
}