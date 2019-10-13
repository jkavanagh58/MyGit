<# Using pswriteexcel
.LINK https://github.com/EvotecIT/PSWriteExcel
    Reference for PSWriteExcel Module
#>
$filename = "c:\etc\testing.xlsx"
$excelWkBook = New-ExcelDocument -Verbose
$excelSheet = Add-ExcelWorkSheet -ExcelDocument $excelWkbook -WorksheetName "Testing"
$excelDat = get-process
$excelInfo = Add-ExcelWorksheetData -ExcelDocument $excelWorkBook -Option Replace -ExcelWorksheet $excelSheet -DataTable $excelDat -AutoFit
Save-ExcelDocument -ExcelDocument $excelWkBook -FilePath $filename


<# Using ImportExcel
.LINK https://github.com/dfinke/ImportExcel
    Reference for ImportExcel Module
#>
get-process | Export-Excel -Path $filename -WorksheetName "Processes" -AutoSize -TableName "Processes"