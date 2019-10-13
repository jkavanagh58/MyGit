<#
    .SYNOPSIS
        Quick function to create a Cert for Signing Code
    .Link https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/creating-code-signing-certificates
        The source of this code via Idera PowerShell tips
    .NOTES
        ===========================================================================
        Created with:	Visual Studio Code
        Created on:		05.08.2019
        Created by:		Kavanagh, John J.
        Organization:	TEKSystems
        Filename:		Should be placed in a profile or module
        ===========================================================================
        05.08.2019 JJK: Removed Positional Parameter designation
        05.08.2019 JJK: Added CmdletBinding
        05.08.2019 JJK: Added CBH
        05.08.2019 JJK: Splatted cmdlet syntax
#>
function New-CodeSigningCert {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [System.String]$FriendlyName,
        [Parameter(Mandatory)]
        [System.String]$Name
    )
    Write-Debug -Message "[DEBUG] You are creating CN=$Name"
    # Create a certificate
    $newSelfSignedCertificateSplat = @{
        TextExtension = @('2.5.29.37={text}1.3.6.1.5.5.7.3.3')
        KeySpec = 'Signature'
        NotAfter = (Get-Date).AddYears(5)
        KeyUsage = 'DigitalSignature'
        Subject = "CN=$Name"
        KeyExportPolicy = 'ExportableEncrypted'
        FriendlyName = $FriendlyName
        CertStoreLocation = 'Cert:\CurrentUser\My'
    }
    New-SelfSignedCertificate @newSelfSignedCertificateSplat
}