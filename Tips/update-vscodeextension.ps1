# // The commands to interact with Visual Studio code
<# 
	/*
		Visual Studio Code (Stable):  code
		Visual Studio Code (Insiders): code-insiders

		Note: if you mistype anything after the code command name you will be 
		rewarded with a new VSCode blank session
	/*
#>
# Find the command(s) available because yes you can install both versions on a machine
Get-command -Name code*

# Help for the vscode command
code --help

<# //
	.LINK https://code.visualstudio.com/Docs/editor/extension-gallery
		Documentation for Extension Management in Visual Studio Code
	.LINK https://github.com/Microsoft/vscode/issues/155
		Setting in settings.json necessary if working behind a proxy server
// #>
#Command to list the installed extensions
code --list-extensions

# Command to install an extension
code --install-extension gerane.Theme-Blackboard
# Any currently open VSCode session will show the extension is installed but with the "Reload"
# moniker present
(get-process).where{$_.ProcessName -eq "code" -Or $_.ProcessName -eq "Code - Insiders"}.Foreach{$_.kill()};code-insiders
(get-process).where{$_.ProcessName -eq "code" -Or $_.ProcessName -eq "Code - Insiders"}.Foreach{$_.kill()};code



# Possible way to use it in a scripted fashion
Function update-newvscode {
[CmdletBinding()]
param (
	[System.Array]$curExtensions,
	[System.String]$refMachine = "INFO-67TVF72",
	[System.Array]$refExtensions,
	[System.String]$codeCommand = (get-command -Name Code*).Name.Replace(".cmd",""),
	$needExtensions
)
BEGIN {
	If ($codeCommand.Count -gt 1){
		Write-Error -Message "Hey I said this was a quick example"
		Write-Error -Message "Pick one version or the other I am not working on two"
		start-sleep -Seconds 2
		EXIT
	}
	$curExtensions = invoke-command -ScriptBlock {powershell -command "$codeCommand --list-extensions"}
	$invokeCommandSplat = @{
		ComputerName = $refMachine
		ScriptBlock  = {powershell -nologo -noprofile -Command "$using:codeCommand --list-extensions"}
	}
	$refExtensions = Invoke-Command @invokeCommandSplat
}
PROCESS {
	$needExtensions = compare-object -ReferenceObject $refExtensions -DifferenceObject $curExtensions
	ForEach ($thisExtension in $needExtensions){
		$thisExtension.InputObject
		$installCmd = "$codeCommand --install-extension $thisExtension.InputObject"
		Write-Verbose -Message "[PROCESS]Installing "
		Try {
			"Invoke-command -ScriptBlock {$installCmd}"
		}
		Catch {
			Write-Error -Message "Unable to install $($thisExtension.InputObject) extension"
		}
	}
}
END {
	Remove-Variable -Name curExtensions, refExtensions, needExtensions, invokeCommandSplat
	[System.GC]::Collect()
}
}