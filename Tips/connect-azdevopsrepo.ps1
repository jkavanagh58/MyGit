# You must have git installed
# install from git
if (git.exe) {
    "All Good"
}
Else {
    "No git"
    # Will try Chocolatey but depending on version of PowerShell and NuGet
    # This could be support issue
    Install-Package -Name git -ProviderName Chocolatey -Confirm:$False -Verbose -Force
    Invoke-Item Git-2.21.0-32-bit.exe -Path C:\Chocolatey\lib\git.install.2.21.0\tools
    # Or
    $invokeWebRequestSplat = @{
        Headers = @{"Upgrade-Insecure-Requests" = "1"; "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36"; "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3"; "Referer" = "https://git-scm.com/download/win"; "Accept-Encoding" = "gzip, deflate, br"; "Accept-Language" = "en-US,en;q=0.9"}
        Uri = "https://github.com/git-for-windows/git/releases/download/v2.21.0.windows.1/Git-2.21.0-64-bit.exe"
        OutFile = "$env:TEMP\installgit.exe"
    }
    Invoke-WebRequest @invokeWebRequestSplat
    Invoke-Item $env:temp\installgit.exe
}

# Create github folder if necessary
# Set to location of github directory so clone will be
# in an expected location
If (Test-Path $env:USERPROFILE\Documents\Github){
    Set-Location $env:USERPROFILE\Documents\Github
}
Else {
    New-Item -Name github -ItemType Directory -Path $env:USERPROFILE\Documents
    Set-Location $env:USERPROFILE\Documents\Github
}
# Clone from the URL
git clone https://wegit.visualstudio.com/_git/ServiceDelivery
