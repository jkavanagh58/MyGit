Install-Package -Name git -ProviderName Chocolatey
set-location $env:USERPROFILE\Documents
if (test-path github){
    set-location github
}
Else {
    New-Item -Name github -Path $env:USERPROFILE\Documents -ItemType Directory
    set-location github
}
    $genWarning = "Demonstration of ScriptAnalyzer in VSCode - your ISE Can't do that"
git clone https://wegit.visualstudio.com/ServiceDelivery/Automation/_git/ServiceDelivery


