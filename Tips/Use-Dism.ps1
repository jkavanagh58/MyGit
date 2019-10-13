#Requires -RunAsAdministrator
<#
	TIPS - Using PowerShell to enable optional features using DISM
	A few included, hence why you see two lines for the same action.
	Starter - How to use PowerShell to find features that have not been
	enabled.
	First method uses the Where Method. Better performance.
	Second just a play on the standard method but no curly brackets or
	formal declaration of the field to search closer to plain english.
	Use get-command to find commands specific to a module. Example
	get-command -Verb Get -Module Dism
	Use Get-Member to find the object fields and methods.

	And Oh yeah document your code. Comment comment comment.

	NOTE: The DISM related commmands vary based on OS use
	get-command -Module Dism to find the commmand you are looking for.
#>
# Use inline method for performance
(Get-WindowsOptionalFeature -online).Where{$_.state -ne "Enabled"}
# More of a plain english type where statement requires V4 or greater
Get-WindowsOptionalFeature -online | Where Status -ne "Enabled" | get-member
# Now lets find the feature you are looking for by extending Where clause
# We are looking for Microsoft-Windows-Subsystem-Linux
(Get-WindowsOptionalFeature -online).Where{$_.state -ne "Enabled" -and $_.FeatureName -like "*Linux*"}
# Now let's enable, use ForEach because Feats like Hyper-V include several ... do some
# research because I am writing this is an example, you might not want all features enabled
# I am using the methods because yeah I think it looks cooler but you could use the pipeline
# to do the same thing but I push for performance. Sadly the enable cmdlet does not include the 
# WhatIf parameter
# Warning this use of the enable-WindowsOptionalFeature will start a restart if necessary, if you want to 
# hold off the restart there is a parameter named NoRestart which will not prompt for a restart so the
# Feature you enabled may not be fully impletemented until the next restart
(Get-WindowsOptionalFeature -online).Where{$_.state -ne "Enabled" -and $_.FeatureName -like "*Linux*"}.ForEach{Enable-WindowsOptionalFeature -FeatureName $_.FeatureName -Online}
