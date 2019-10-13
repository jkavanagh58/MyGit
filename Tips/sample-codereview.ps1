$reviewTime = [System.Diagnostics.Stopwatch]::StartNew()
$reviewPath = 'C:\Users\johnk\Documents\GitHub\ServiceDelivery\Tips'
$reviewfiles = Get-ChildItem -Path $reviewPath
# Just to trigger InjectionHunter
Invoke-Expression -Command "echo NothingtoseeHere"
$invokeScriptAnalyzerSplat = @{
    Settings = 'C:\Users\johnk\Documents\GitHub\ServiceDelivery\Tips\PSScriptAnalyzerSettings.psd1'
    Path = $reviewPath
    ErrorAction = 'SilentlyContinue'
}
$reviewdat = Invoke-ScriptAnalyzer @invokeScriptAnalyzerSplat
"Review took {0} Seconds to run against {1} files" -f [Math]::Round($reviewTime.Elapsed.TotalSeconds,1), $reviewfiles.count
# Let's view the stats
$reviewdat | group rulename | sort-Object -Property count -Descending | select-object -Property Count, Name -First 10 
$reviewWorkbook = Join-Path $reviewPath -ChildPath "CodeReview.xlsx"
$reviewSheet = "Review$(Get-Date -Format 'MMddyyyy')"
$reviewdat | Select-Object ScriptName, RuleName, Severity | Sort-Object -Property Severity | 
Export-Excel -Path $reviewWorkbook -WorksheetName $reviewSheet -TableStyle Medium3 -TableName $reviewSheet -ClearSheet