[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    
)

# Would need to establish at runtime
If (!($VerbosePreference = "Continue")){
    $VerbosePreference = Continue
}
Write-Verbose -Message "[BEGIN]This started at $(Get-Date -Format 'MM.dd.yyyy')"
"Do something"
if ($PSCmdlet.ShouldProcess("Modules" , "Listing Installed")) {
    Get-InstalledModule
}
Write-Verbose -Message "[BEGIN]This ended at $(Get-Date -Format 'MM.dd.yyyy')" 

