#Requires -RunAsAdministrator
<#
    .LINK https://www.thomasmaurer.ch/2019/03/how-to-install-and-update-powershell-6/
        Great reference for a way to install and update PowerShell Core; Link also
        includes a solid reference to run it on most linux distros
#>
# iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"
#$installCore = "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
#Invoke-Command -Command $installCore
Invoke-RestMethod https://aka.ms/install-powershell.ps1 | out-file $env:temp\install-core.ps1
Write-Verbose -Message "[PROCESS]Running Install-Core script"
& $env:temp\install-core.ps1 -UseMSI -Quiet
Write-Verbose -Message "[PROCESS]Removing Install Script"
Remove-item $env:temp\install-core.ps1 -Verbose