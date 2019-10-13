Param(
    [Parameter(Mandatory = $true)]
    [String]$UserName
)
if (!(Get-Module -ListAvailable -Name psPAS)) {
    Write-Host -ForegroundColor Yellow "Missing psPAS module. Pulling from gallery."
    Install-Module -Name psPAS -Scope CurrentUser
}

$token = New-PASSession -Credential $(Get-Credential) -BaseURI "https://cyberark" -SecureMode $true -type RADIUS 
$accountID = $token | Get-PASAccount -Keywords "$UserName wfm.wegmans.com" | Select-Object -ExpandProperty AccountID
$token | 
$arkpass = Get-PASAccountPassword -AccountID $accountID | Select-Object -ExpandProperty Password
$password = convertto-securestring -String $arkpass -AsPlainText -Force
$admcreds = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
