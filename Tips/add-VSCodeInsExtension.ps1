<#
    .SYNOPSIS
        Installs base VScode-insidersExtensions
    .DESCRIPTION
        Uses list of recommended extensions to start using VScode-insiderswith PowerShell.
    .NOTES
        ===========================================================================
        Created with:	Visual Studio Code
        Created on:		08.12.2018
        Created by:		Kavanagh, John J.
        Organization:	TEKSystems
        Filename:		Add-VSCodeExtension
        ===========================================================================
        08.12.2018 JJK: Assembling list of VScode-insidersextensions to help get a user started
                        with VScode-insidersand PowerShell
        08.12.2018 JJK: TODO: Research the availability of code.cmd as it has not been existent
                        even after successful installation.
        08.14.2018 JJK: Made into a stand-alone script since install method may change
        08.14.2018 JJK: Added PowerShell extension <see note above>
        08.14.2018 JJK: Only install extension if not found in list of installed extensions
        09.07.2018 JJK: DONE: Add process to copy snippet files to user location
        10.04.2018 JJK: DONE: Add Azure specific extensions
        10.04.2018 JJK: TODO:Verify location of Snippet file
        12.14.2018 JJK: Extension list updated
#>
Function Add-VSCodeExtension {
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $False, ValueFromPipeline = $False,
            HelpMessage = "Collection of Recommended Extensions")]
        $extList
    )
    BEGIN {
        If (get-command -Name code.cmd -ErrorAction SilentlyContinue) {
            $extInstalled = code-insiders--list-extensions
            # Build list of extensions
            $extList = New-Object System.Collections.ArrayList
            $extList.Add("ms-vscode.PowerShell") | Out-Null
            $extList.Add("docsmsft.docs-article-templates") | out-Null
            $extList.Add("docsmsft.docs-markdown") | Out-Null
            $extList.Add("docsmsft.docs-preview") | Out-Null
            $extList.Add("ms-azuretools.vscode-azureappservice") | Out-Null
            $extList.Add("ms-azuretools.vscode-azurefunctions") | Out-Null
            $extList.Add("ms-azuretools.vscode-azurestorage") | Out-Null
            $extList.Add("ms-azuretools.vscode-cosmosdb") | Out-Null
            $extList.Add("ms-docfx.DocFX") | Out-Null
            $extList.Add("ms-mssql.mssql") | Out-Null
            $extList.Add("ms-python.python") | Out-Null
            $extList.Add("ms-vscode.azure-account") | Out-Null
            $extList.Add("ms-vscode.azurecli") | Out-Null
            $extList.Add("ms-vscode.vscode-node-azure-pack") | Out-Null
            $extList.Add("ms-vsliveshare.vsliveshare") | Out-Null
            $extList.Add("ms-vsts.team") | Out-Null
            $extList.Add("nachocab.highlight-dodgy-characters") | Out-Null
            $extList.Add("oderwat.indent-rainbow") | Out-Null
            $extList.Add("nobuhito.printcode") | Out-Null
            $extList.Add("redhat.vscode-yaml") | Out-Null
            $extList.Add("sidthesloth.html5-boilerplate") | Out-Null
            $extList.Add("VisualStudioOnlineApplicationInsights.application-insights") | Out-Null
            $extList.Add("DougFinke.vscode-PSStackoverflow") | Out-Null
            $extList.Add("formulahendry.azure-storage-explorer") | Out-Null
            $extList.Add("gerane.Theme-Blackboard") | Out-Null
            $extList.Add("hfac.msdos-theme") | Out-Null
            $extList.Add("ionicabizau.ms-dos-editor-theme") | Out-Null
            $extList.Add("karb0f0s.vbscript") | Out-Null
        }
        Else {
            Write-Error "Unable to find the command needed to perform this operation."
            EXIT
        }
    }
    PROCESS {
        ForEach ($extension in $extList) {
            If ($extInstalled -contains $extension) {
                "{0} Already installed" -f $extension
            }
            Else {
                & code-insiders--install-extension $extension
            }
        }
    }
    END {
        Remove-Variable -Name extList
        [System.GC]::Collect()
    }
} # end Add-VSCodeExtension Function
Function Add-Snippetfile {
    # code-insidersto implement PowerShell Snippet file
    $destFolder = Join-Path $env:APPDATA -ChildPath "\Code\User\Snippets"
    If (Test-Path $destFolder -ErrorAction SilentlyContinue) {
        # TODO:Backup existing file if exists
        If (Test-Path $env:APPDATA\Code\User\Snippets\PowerShell.JSON) {
            Rename-Item $env:APPDATA\Code\User\Snippets\PowerShell.JSON -NewName $env:APPDATA\Code\User\Snippets\PowerShell.backup -Force
        }
        Copy-Item \\wfm.wegmans.com\Departments\InformationTechnology\TechWintel\.Scripts\Automation\powershell.json -Destination $destFolder -force
    }
    Else {
        Write-Error -Message "Unable to find path to Snippet files. Is Visual Studio code-insidersinstalled?"
    }
}
# Only because it is being run in haste
Find-Module -Name EditorServices* | % { Install-Module -Name $_.Name -Confirm:$False -Force -Verbose }
Add-VSCodeExtension
Add-snippetfile
