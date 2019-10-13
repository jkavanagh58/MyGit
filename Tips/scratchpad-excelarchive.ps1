$fileActive = "C:\temp\GitActivity.xlsx"
$fileArchive = "c:\temp\gitarchive.xlsx"

$activeSheets = Get-ExcelSheetInfo -Path $fileActive | Where-Object {((get-Date) - (Get-Date($_.Name))).TotalDays -gt 30}
ForEach ($sheet in $activeSheets) {
    # Copy older sheet to archive file
    Write-Information -MessageData "Worksheet moved to Archive File" -InformationAction Continue
    Copy-ExcelWorkSheet $sheet.path -DestinationWorkbook $fileArchive -DestinationWorkSheet $sheet.name
    # Remove from Active Sheet
    Write-Information -MessageData "Removing Worksheet from Active based on date"
    Remove-WorkSheet -Path $sheet.path -WorksheetName $sheet.Name
}
