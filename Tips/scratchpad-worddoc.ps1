
Try {
    Import-Module PSWriteWord
}
Catch {
    Write-Error "You must have the PSWriteWord module installed."
    Exit
}
Function Get-CompInfo { 
    Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Model, Manufacturer, PrimaryOwnerName
}
$ArrayProcs = New-Object System.Collections.ArrayList

$FilePath = "$Env:USERPROFILE\Desktop\PSWriteWord-Example2.docx"
$myDocument = New-WordDocument -FilePath $FilePath
$addWordTextSplat = @{
    WordDocument = $myDocument
    FontFamily   = "Fira Code"
    Text         = "Created this from the shell"
    FontSize     = 14
}
Add-WordText @addWordTextSplat
$aDoc = get-content C:\temp\testing.txt -Raw 
$addWordTextSplat = @{
    WordDocument = $myDocument
    FontFamily   = "Fira Code"
    Text         = "Generated from $($env:COMPUTERNAME)", $aDoc
    FontSize     = 12
}
Add-WordText @addWordTextSplat
# Testing after module gets updated for PSCustomObject issue
$compVals = Get-CompInfo
$addWordTableSplat = @{
	WordDocument = $myDocument
	DataTable    = $compVals
	AutoFit      = 'Contents'
	Design       = 'MediumShading2Accent5'
}
Add-WordTable @addWordTableSplat
# Test using an array
Get-Process | % {
    $val = [PSCustomObject]@{
        ProcessName = $_.ProcessName
        ProcessID = $_.Id
        WorkingSet = $_.WorkingSet
    }
    $arrayProcs.Add($val) | Out-Null
}
#Add-WordTableTitle -Titles "Test"
$addWordTableSplat = @{
	WordDocument = $myDocument
	DataTable    = $arrayProcs
	AutoFit      = "Contents"

}
Add-WordTable @addWordTableSplat
Add-WordParagraph -WordDocument $myDocument 
Add-WordText -Text "Lets look at the current Processes at time of this request" -WordDocument $myDocument -CapsStyle smallCaps 
Add-WordList -WordDocument $myDocument -ListType Bulleted -ListData ($ArrayProcs.ProcessName | select-Object -Unique)
Save-WordDocument -WordDocument $myDocument