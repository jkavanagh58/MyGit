#Requires -Modules ImportExcel, @{ ModuleName="PSWriteWord"; ModuleVersion="0.4.3"}

$snippetInfo = New-Object System.Collections.ArrayList
$snipSource = get-content C:\etc\docthis.json -raw
$jsonObj = $snipSource | ConvertFrom-Json
$hash = @{}
foreach ($property in $jsonObj.PSObject.Properties) {
	#$property.Prefix
	#$hash = @{$property.Name = $property.Value;$property.Prefix = $property.Prefix}
	$newrow = [PSCustomObject]@{
		Name        = $property.Name
		Prefix      = $property.Value.prefix
		Description = $property.Value.Description
	}
	$snippetInfo.Add($newrow) | Out-Null
}
$snippetList = $snippetInfo | Sort-Object -Property Name
# Create cheatsheet in Excel
$exportExcelSplat = @{
	FreezeTopRow  = $True
	Path          = "c:\etc\PSSnippets.xlsx"
	AutoSize      = $true
	WorkSheetname = "VSCode PowerShell Snippets"
	ClearSheet    = $true
}
$snippetList | export-Excel @exportExcelSplat

# Create Word doccument
$snippetDoc = New-WordDocument -FilePath "c:\etc\Snippets.docx"

$addWordTextSplat = @{
	WordDocument = $snippetDoc
	FontFamily   = "Fira Code"
	Text         = "Snippet CheatSheet For VSCode PowerShell"
	FontSize     = 14
	Alignment    = "Center"
}
Add-WordText @addWordTextSplat

Add-WordParagraph -WordDocument $snippetDoc
$addWordTableSplat = @{
    AutoFit = 'Window'
    WordDocument = $snippetDoc
    FontSize = 15, 12, 8
    Color = 'Blue', 'Green', 'Red'
    FontFamily = 'Arial', 'Tahoma'
    DataTable = $snippetList
    Bold = $true, $false, $false
}
Add-WordTable @addWordTableSplat

Save-WordDocument -WordDocument $snippetDoc 