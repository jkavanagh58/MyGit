#requires -Version 5
<#
.SYNOPSIS
	Creates self-signed certificate used to sign scripts.
.DESCRIPTION
	Creates self-signed certificate used to sign scripts.
.PARAMETER pfxPath
	Specifies a path to write the pfx certificate created in the process.
.PARAMETER Password
	After operator enters the password to be used for certificate process this variable
	is used for securing generated Pfx certificate.
.EXAMPLE
	I ♥ PS # .\new-signingcert.ps1
	Example of how to use this script
.EXAMPLE
	I ♥ PS # .\new-signingcert.ps1 -Import
	Example of how to use this script to create a new pfx certificate and importing the certificate
	into the local certificate store.
.INPUTS
	Password secure string
.OUTPUTS
	PFX file for import
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		10.31.2017
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		new-signingcert.ps1
	===========================================================================
	10.31.2017 JJK: DONE: Implement process to import created Pfx. Use command line option.
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
Param(
	$pfxPath = "$env:temp\codeSignCert.pfx",
	[Switch]$Import
)
Begin {
	# you'll need this password to load the PFX file later
	$Password = Read-Host -Prompt 'Enter new password to protect certificate' -AsSecureString
}
Process {
	# Create certificate
	# Parameters for new-selfsignedcertificate
	$newSelfSignedCertificateSplat = @{
		TextExtension = @('2.5.29.37={text}1.3.6.1.5.5.7.3.3')
		KeySpec = 'Signature'
		NotAfter = (Get-Date).AddYears(5)
		KeyUsage = 'DigitalSignature'
		Subject = 'CN=SecurityDepartment'
		KeyExportPolicy = 'ExportableEncrypted'
		FriendlyName = 'TechWintel'
		CertStoreLocation = 'Cert:\CurrentUser\My'
	}
	$cert = New-SelfSignedCertificate @newSelfSignedCertificateSplat
	# Export new certificate for import
	$cert | Export-PfxCertificate -Password $Password -FilePath $pfxPath
	If ($Import){
		# Process to import
		Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation cert:\localMachine\my
	}
}
End {
	# Cleanup
	$cert | Remove-Item
	Remove-Variable -Name cert, pfxPath, Password
	[System.GC]::Collect()
}