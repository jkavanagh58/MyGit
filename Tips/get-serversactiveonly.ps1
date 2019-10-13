get-adcomputer -Filter {OperatingSystem -like "*Windows Server*"} -Properties PasswordLastSet |
	Where-Object {((get-date)-$_.PasswordLastSet).TotalDays -lt 31} |
	Select-Object -Property Name, PasswordLastSet, @{N="DaysElapsed";e={((get-date)-$_.PasswordLastSet).TotalDays}} |
	sort-object -Property Name


	# Make a tool out of it

Function Get-ActiveServers {
	<#
		.SYNOPSIS
			Retrieve list of only active servers in a domain
		.DESCRIPTION
			Retrieve list of only active servers in a domain
		.PARAMETER Domain
			Specifies the AD domain to query with get-adcomputer. If no value is provided at runtime a default value
			is the current domain of the user.
		.EXAMPLE
			I ♥ PS >_ $variable = Get-ActiveServers
			Example of how to use this function
		.OUTPUTS
			Selected.Microsoft.ActiveDirectory.Management.ADComputer
		.NOTES
			===========================================================================
			Created with:	Visual Studio Code
			Created on:		04.24.2018
			Created by:		Kavanagh, John J.
			Organization:	TEKSystems
			Filename:		get-serversactiveonly.ps1
			===========================================================================
			04.24.2018 JJK: DONE: Provide mechanism to run against an alternate domain
			04.24.2018 JJK: TODO: Allow for certain property sets to be returned using Switch parameter
			04.24.2018 JJK: TODO: Add function to Wegmans module
			04.24.2018 JJK: DONE: Test splatting for get-adcomputer
			07.12.2018 JJK: Added memory cleanup
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$False,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,
			HelpMessage="Enter a Domain NetBIOSName or DNSRoot to list computers from an alternate domain.")]
		[System.String]$Domain=(Get-ADDomain -Current LoggedOnUser).DNSRoot,
		[System.Collections.Hashtable]$getADComputerSplat
	)
	PROCESS {
		$getADComputerSplat = @{
		    Filter = {OperatingSystem -like "*Windows Server*"}
		    Properties = 'PasswordLastSet'
		    Server = $Domain
		}
		Get-ADComputer @getADComputerSplat |
			Where-Object {((get-date)-$_.PasswordLastSet).TotalDays -lt 31} |
			Select-Object -Property Name, PasswordLastSet, @{N="DaysElapsed";e={((get-date)-$_.PasswordLastSet).TotalDays}} |
			sort-object -Property Name
	}
	END {
		Remove-Variable -Name getADComputerSplat
		[System.GC]::Collect()
	}
}