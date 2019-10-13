param([string]$file, [string]$errorText, $debug, $executedAsTask)
if ($debug -ne "true"){$debug = [bool]$false}else{$debug = [bool]$true}
if ($executedAsTask -ne "true")
{
$executedAsTask = [bool]$false
}
else{$executedAsTask = [bool]$true}   
$Script:API = new-object -comObject "MOM.ScriptAPI" 
$Script:Bag  = $Script:API.CreatePropertyBag() 
$Script:LOG_ERROR = 1 
$Script:LOG_WARNING = 2 
$Script:LOG_INFORMATION = 4 
$Script:ScriptName = "code4ward.Sample.PowerShellMonitor.ps1" 
$Script:Arguments = "Received Arguments:`rFile = $file`rErrorText = $errorText`rDebug = $debug`rExecutedAsTask = $executedAsTask"   
function Write-DebugInfo([string] $msg) {
if ($debug)
{
	$Script:API.LogScriptEvent("$ScriptName",100,$Script:LOG_INFORMATION,"`r$Arguments`r`r$msg")     
} 
} 
function Write-ErrorInfo([string] $msg) {
	$Script:API.LogScriptEvent("$ScriptName",500,$Script:LOG_ERROR,"`r$Arguments`r`r$msg") 
}   
Write-DebugInfo "Script started..."   
if ($file.Trim().Length -gt 0)
{
	$FileExists = (Test-Path $file) 
} 
else {
	Write-ErrorInfo "No file was specified."     return 
}         
if (-not $FileExists)  
{
	Write-ErrorInfo = "File '$file' not found."     return 
}     
$File = Get-Item $file 
[string]$FileContent = @() 
foreach ($Line in Get-Content $File) {
	$FileContent += "`r$Line" 
}       
if ($errorText.Trim().Length -gt 0) 
{
	if ($FileContent.Contains($errorText))
	{
		$Script:Bag.AddValue("Status","ERROR")
		$Script:Bag.AddValue("MessageText","Error text '$errorText' found in file '$file'.")
	}
	else 
	{
		$Script:Bag.AddValue("Status","OK")
		$Script:Bag.AddValue("MessageText","Error text '$errorText' not found in file '$file'.")     
	}
	if ($executedAsTask)
	{
		$Script:Bag.AddValue("AdditionalStuff","goes here")     
	} 
}
else {     Write-ErrorInfo "No error text specified" }   
#$Script:API.Return($Bag) 
$Script:Bag   
Write-DebugInfo "Script ended..."