Function Read-OpenFileDialog {
Param(
	[String]$WindowTitle,
	[String]$InitialDirectory,
	[String]$Filter = "All Files (*.*)|*.*",
	[Switch]$AllowMultiSelect
)
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | out-Null
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Title = $WindowTitle
If (![String]::IsNullOrWhiteSpace($InitialDirectory)){$openFileDialog.InitialDirectory = $InitialDirectory}
$openFileDialog.Filter = $Filter
If ($AllowMultiSelect){$openFileDialog.MultiSelect = $True}
$openFileDialog.ShowHelp = $True
$openFileDialog.ShowDialog() > $null
If ($AllowMultiSelect){return $openFileDialog.Filename} else {return $openFileDialog.Filename}
}