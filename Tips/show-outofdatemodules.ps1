Function show-outofdatemodules {
#Requires -Version 5
    <#
        Quick module to simply list any module you have installed
        that is not the current version.
        NOTE: For easy access place this function in your PowerShell profile for easy access.
    #>
	[CmdletBinding()]
	Param (
		[System.Array]$varModules = (get-installedmodule)
	)
	BEGIN {

	}
	PROCESS{
		$i=0
		ForEach ($curModule in $varModules | Sort-Object -Property Name) {
            $i++    # Progress counter
			Write-Progress -Activity "Checking Module" -CurrentOperation $curModule.Name -PercentComplete ($i/$varModules.count*100)
			If ($curModule.Version -lt (find-module -Name $curModule.Name).Version) {
				"{0} module is currently out of date" -f $curModule.Name
			}
		}
	}
	END {
		Remove-Variable -Name varModules, i
		[System.GC]::Collect()
	}
}