<#
.SYNOPSIS
	Digitally signs a script file.
.DESCRIPTION
	Digitally signs a script file. Uses the Code signing certificate installed in the Personal certificate
	library.
.PARAMETER sFile
	Name (full path) of script to digitally sign.
.PARAMETER cert
	Certificate to be used to digitally sign the file.
.EXAMPLE
	I ♥ PS >_ .\sign-scriptfile.ps1 c:\etc\scripts\new-something.ps1
	Example of how to use this script to digitally sign a script file.
.EXAMPLE
	I ♥ PS >_ gci *.ps1 -Path c:\scripts | %{.\sign-script.ps1 -sfile $_.FullName}
	Another example of how to use this script to digitally sign a directory of scripts.
.INPUTS
	File name
.NOTES
	===========================================================================
	Created with:	Visual Studio Code
	Created on:		10.27.2017
	Created by:		Kavanagh, John J.
	Organization:	TEKSystems
	Filename:		sign-scriptfile.ps1
	===========================================================================
	11.01.2017 JJK:	DONE: Check to see if file is already signed.
	11.01.2017 JJK:	TODO: Add ability to save signed script to different path.
	11.01.2017 JJK:	TODO: Verify a certificate is available..
	05.01.2018 JJK:	TODO: Based on new information for the $cert variable statement will need 
					complete path within the LocalMachine structure
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
Param(
	[Parameter(ValueFromPipeline=$true, Mandatory=$true)]
	[ValidateScript({Test-Path -Path $_})]
	[Alias("Script","ScriptFile")]
	[String]$sfile
)
BEGIN {
	# Find codesigning certificate
	$cert = @(Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert)[0]
	# Based on information gleaned during recent troubleshooting issues
	$cert = @(Get-ChildItem Cert:\LocalMachine\My -CodeSigningCert)[1]
}
PROCESS {
	# Uses first certificate found with codesigning defined as purpose
	If ($cert){
		If ((get-authenticodeSignature -FilePath $sFile).Status -ne "Signed"){
			"Signing $sfile"
			Set-AuthenticodeSignature -FilePath $sfile -Certificate $cert #-IncludeChain
		}
		Else {
			"{0} is already signed" -f $sfile
		}
	}
}
END {
	Remove-Variable -Name sfile
	[System.GC]::Collect()
}
# SIG # Begin signature block
# MIIFdgYJKoZIhvcNAQcCoIIFZzCCBWMCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUK7GT72s99+qgHjPaPCeVNrM
# JrKgggMOMIIDCjCCAfKgAwIBAgIQX/WK2fVmO4tHgFQJyxClqzANBgkqhkiG9w0B
# AQUFADAdMRswGQYDVQQDDBJTZWN1cml0eURlcGFydG1lbnQwHhcNMTgwNTAyMTIy
# MjMxWhcNMjMwNTAyMTIzMjMxWjAdMRswGQYDVQQDDBJTZWN1cml0eURlcGFydG1l
# bnQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCeyTztkV4Y/VxOsuzo
# sW3mWLWRChjMuxyzq1PLW+RtT2X8a/RY50p4Cw0qVeZdtU2wcO9807xiON1vrEN1
# 8SliaFRfCGgniaWRC3WHPgXYLr0gbjXVhAFegEHd5TqeqBSdyzFcIoVC3Fp2mKId
# bGGYv67mMxRWN3kVgLMn0I0WgNjkiMeyjecKGz1fAFNCSHQmg9m+qagZN9ew27H2
# Mo5nCKrGoVs28Y7vHjWZPoGjx7lLOPLWkxfQPSrBbvM8j4VoQu/sluVkzqNvus7g
# sb0yGuy/vwkRQSN2bnHjSvSfdQeXxeMJ1oUXqC7fyWqXVutX7w63FIHPhDYQ2Yfn
# xrLpAgMBAAGjRjBEMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcD
# AzAdBgNVHQ4EFgQUSxhhI2DhxGgZTD4FcOtEbXyp7pgwDQYJKoZIhvcNAQEFBQAD
# ggEBAI2MUXaAGynjQQYBuV9M5wNw4JUe1Vr0pw9zkGgDEu++YmJD0yUSRvQeluQz
# AFUufNIf95kc+TFlTPENTwaa2Z8AAnbzv+aQSjVx0C2yFOt953+/ymo+siISub5+
# N8Ebr57pPk+quVPr7fx6nAXh0th5gSWUjD+3OGBDjnIq6gQrTl9Yng8bC9ULfCDH
# T/eosnGBvRYOqENf6RGYLQW8Z898kadlvP2QQLS6vcKgbwbY96ffXLLTwS2urdJZ
# FrQh/x+W1w3YtCGkO83YDZkG4Ds27Prz1eJFI3RA+ugdsB0nHYjWSwggp81A+ciW
# S4jkr1dDU19Hy5QRSkyKn9LeM1YxggHSMIIBzgIBATAxMB0xGzAZBgNVBAMMElNl
# Y3VyaXR5RGVwYXJ0bWVudAIQX/WK2fVmO4tHgFQJyxClqzAJBgUrDgMCGgUAoHgw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQx
# FgQUmfZ+84HAjT2hnwYOyHHvkxSv5TAwDQYJKoZIhvcNAQEBBQAEggEAaflEOPHN
# 1Pf47LKf2ha5OPopTNZQniUwSQMMt/D8EGuHZ8nnNxm1DRzkbkrXYmDcUoNuUNba
# AaNJpcN8SudXa2DjUN5VcfwyJBMB3laEpDPUZ27U1CQtBnXMf1zvUJnbAlfEOwiD
# tMQtL4/qQTqxl1NJCACSkEquEM0hdRXdC3fmRBoAp4+w7rH2OsyIKW7c8JtekDkd
# BQ1NHiPcNEpKBAtgxIIs9ePNWYfALtQB8e5MtD1mE9vcxp4+SPlIW5S3FbTGy2ww
# TzaPiou8tO7aDNFJ0jtT6vzcddu3GqV1o7b44iC2OnAyQbugYimCbL0I0bnNBfWH
# HaMYsEbd2ZyiAg==
# SIG # End signature block
