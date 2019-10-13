# Migrate VSCode Snippets
BEGIN {
	$curPath = "C:\Users\vndtekjxk\AppData\Roaming\Code\User\snippets"
	#$insPath = "C:\Users\vndTekJXK\AppData\Roaming\Code - Insiders\User\snippets"
	$remPath = "\\wks-jkavanag-01\vndtekjxk\AppData\Roaming\Code - Insiders\user\snippets"
	$snipFiles = "powershell.json", "xml.json"
}
PROCESS {
	ForEach ($snipFile in $snipfiles){
		$snipObject = Join-Path -Path $curPath -ChildPath $snipFile
        $destObject = Join-Path -Path $remPath -ChildPath $snipFile 
        $destObject
        $olderFile = (Get-ChildItem $snipObject).LastWriteTime -ge (Get-Childitem $destObject).LastWriteTime
        $largerFile = (Get-ChildItem $snipObject).Length -ge (Get-Childitem $destObject).Length
		If (Test-Path $destObject){
			# Compare FileSize since a Snippet file already exists
			If ((Get-ChildItem $snipObject).LastWriteTime -ge (Get-Childitem $destObject).LastWriteTime) {
                # Source file is newer, copy to destination
                "Source file is more current than destination"
				Copy-Item -Path $snipObject -Destination $destObject -Force
			}
			ElseIf ((Get-ChildItem $snipObject).Length -ge (Get-Childitem $destObject).Length) {
                # Source file is larger, copy to destination
                "Source file is larger than destination file"
				Copy-Item -Path $snipObject -Destination $destObject -Force
			}
		}
		Else {
			# File does not exist
			copy-item -Path $snipObject -Destination $destObject -Force
		}
	}
}