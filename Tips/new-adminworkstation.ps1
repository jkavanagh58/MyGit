#Requires -Version 5
#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Add-on script to install standard utilities for win admin workstation
.DESCRIPTION
    This script is designed for Windows10 machines, when a Windows Admin builds a new windows workstation. Uses Powershell Package Manager and chocolatey.
.NOTES
    ===========================================================================
    Created with:	Visual Studio Code
    Created on:		10.04.2015
    Created by:		Kavanagh, John J.
    Organization:	TEKSystems
    Filename:		new-adminworkstation.ps1
    ===========================================================================
    11.23.2018 JJK:	TODO: Add routing to update module if already installed
    04.23.2019 JJK: TODO: Consider installing git as a standard
    04.23.2019 JJK: TODO: move suggestedmodules to Param statement
#>
[CmdletBinding()]
Param (
    [parameter(Mandatory = $False, ValueFromPipeline = $False,
        HelpMessage = "Chocolatey Package Installs")]
    [System.String]$packagesChocolatey = "sysinterals, RDCMan"
)
BEGIN {
    # Array of suggested modules
    $suggestedModules = @("PowerCLI", "msonline", "importExcel", "AZ", "Pester", "AzureAD", "EditorServicesCommandSuite", "EditorServicesProcess")
}
PROCESS {
    # Make sure NuGet is a registered Provider
    If (!(get-packageprovider -Name "NuGet" -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name "NuGet"
    }
    # Install Suggested Modules
    ForEach ($module in $suggestedModules) {
        If (!(get-installedmodule -Name $module -ErrorAction SilentlyContinue)) {
            $installModuleSplat = @{
                Scope   = 'AllUsers'
                Name    = $module
                Verbose = $true
                Force   = $true
            }
            Install-Module @installModuleSplat
        }
        Else {
            Write-Information -Messagedata "Module already installed" -InformationAction Continue
        }
    }
    # Use Chocolatey Package Provider to install additional software
    # Add Chocolatey repository to Powershell V4
    if (!(get-packagesource -Name Chocolatey)) {
        Register-PackageSource -Name chocolatey -Provider chocolatey -Trusted –Location http://chocolatey.org/api/v2/
    }
    # Validate Chocolatey is trusted
    if (!(get-packagesource).IsTrusted) { get-packagesource chocolatey | Set-PackageSource -Trusted -Verbose }
    # Start installing software
    ForEach ($package in $packagesChocolatey) {
        if (!(get-package -name $package)) {
            $installpackageSplat = @{
                Name         = $package
                Scope        = 'AllUsers'
                ProviderName = 'Chocolatey'
            }
            install-package @installpackageSplat
        }
    }
    # For git we need additional data to complete the install
    $gitData = find-package -name git -ProviderName Chocolatey
    $gitInstaller = join-path C:\Chocolatey\lib -ChildPath "git.install.$($gitData.Version)\tools"
    $gitExecutor = "git-$($gitData.Version)-64-bit.exe"
    invoke-Item "$gitInstaller\$gitExecutor /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCANCEL /SP-"
}
END {
    Remove-Variable -Name installpackageSplat, installModuleSplat, packagesChocolatey
    [System.GC]::Collect()
}