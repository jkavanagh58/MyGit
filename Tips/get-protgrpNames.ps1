#Requires -Modules ImportExcel
$xlsxPath = "C:\Users\vndtekjxk\OneDrive - Wegmans Food Markets, Inc\Documents\SRM"
$xlsxName = "SRM1.xlsx"
$xlsxFile = Join-Path $xlsxPath -ChildPath $xlsxName
If (Test-Path $xlsxFile) {
    $dataSet = Import-Excel -Path $xlsxFile -WorksheetName Sheet1 -DataOnly
    $dataSet | Select-Object -Property Group -Unique | sort-object -Property Group
}