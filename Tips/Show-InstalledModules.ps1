Function show-installedmodules {
#Requires -Modules PowerShellGet   
    <#
    .SYNOPSIS
        Lists Installed Modules and compares installed versions compared to online version
    .DESCRIPTION
        Uses list of installed modules via Get-InstalledModule, and compares them to current online version using
        the Find-Module returned Version. Place in profile to ensure it is loaded in all PowerShell sessions is
        recommended.
    .EXAMPLE
        I ♥ PS  > show-installedmodules
        Example of how to use this Function
    .NOTES
        ===========================================================================
        Created with:   Visual Studio Code
        Created on:     10.01.2017
        Created by:     Kavanagh, John J.
        Organization:   KavanaghTech
        Filename:       system-functions.ps1
        ===========================================================================
        05.29.2018 JJK: Done:Add script cleanup
    #>
    [CmdletBinding()]
    Param(
        $varModules = (get-installedmodule)
    )
    BEGIN {
        "-" * 52
        "`tReporting on {0} modules" -f $varModules.Count
        "-" * 52
    }# End Begin
    PROCESS {
        <#
        $varModules |
            sort-object -Property Name |
            select-object -Property  Name,
                                     Version,
                                     @{
                                         Label = "Online Version";
                                        Expression = {(find-module -Name $_.Name).Version}
                                    } |
            format-table -AutoSize
        #>
        ForEach ($varModule in $varmodules | Sort-Object -Property Name) {
            Write-Verbose -Message "[ROCESS]Checking online Version for $($varModule.Name)"
            [Version]$onlineVersion = (Find-Module -Name $varModule.Name).Version
            [Version]$localVersion = $varModule.version
            if ($onlineVersion -gt $localVersion) {
                Write-Host "$($varModule.Name)" -NoNewLine
                Write-Host "`t$($localVersion)" -ForegroundColor Yellow -NoNewline
                Write-Host "`t$($onlineVersion) Consider updating" -ForegroundColor Green
            }
            <#
            Else {
                Write-Host "$($varModule.Name)" -NoNewLine
                Write-Host "`t$($varModule.Version)" -ForegroundColor Yellow -NoNewline
                Write-Host "`tCurrent version is: $($onlineVersion)" -ForegroundColor Red
            }
            #>
        }
    }# End Process
    END {
        Remove-Variable -Name varmodules
        [System.GC]::Collect()
    }
}