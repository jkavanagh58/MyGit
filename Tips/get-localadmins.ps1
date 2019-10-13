#requires -module ActiveDirectory
<#
	.SYNOPSIS
		Audit Local Administrators group of all servers.

	.DESCRIPTION
		Queries active directory for all computers running a server version of Windows. For each returned object
		if the instance is online, ADSI is used to list members of the local Administrators group.

	.EXAMPLE
		 C:\etc\Scripts\get-localadmins.ps1 | clip

	.OUTPUTS
		System.String

	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.3.130
	 Created on:   	12/2/2016 6:20 AM
	 Created by:   	John Kavanagh
	 Organization: 	Sparks IT Group
	 Filename:  	get-localadmins.ps1
	===========================================================================
#>
function Get-lcladmins {
<#
	.SYNOPSIS
		List members of server local administrators group
	.DESCRIPTION
		List members of server local administrators group
	.PARAMETER machine
		String value placed in the WinNT ADSI string.
	.LINK
		https://msdn.microsoft.com/en-us/library/aa772211(v=vs.85).aspx
#>
[CmdletBinding()]
param
	(
		[Parameter(Mandatory = $true)]
		[string]$machine = "."
	)

	$group = [ADSI]("WinNT://$machine/Administrators,group")
	$varMembers = $group.psbase.invoke("Members")
	"--------- {0} ---------" -f $machine
	$varMembers | %{ $_.GetType().InvokeMember("Adspath", 'GetProperty', $null, $_, $null) }
}

<#
$varServers = get-adcomputer -filter { OperatingSystem -like "*server*" } | sort Name
foreach ($srv in $varServers) {
	if (Test-Connection -ComputerName $srv.Name -Count 1 -Quiet -ErrorAction SilentlyContinue) {
		Get-lcladmins $srv.Name
	}
}
#>