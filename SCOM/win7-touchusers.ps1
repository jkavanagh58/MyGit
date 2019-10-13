<#
Script definition and change notes
.SYNOPSIS
   Update User Objects for Win7 Migtration
.DESCRIPTION
   For each member of the source group the Active Directory user object is
   updated with LogonScript, HomeDrive if not already H:, new ProfilePath 
   and HomeDirectory (both generated using new Standards).  Script uses
   Quest AD Cmdlets.  Each session is recorded for troubleshooting using
   the Transcript dated for the current date.
.LINKS
	http://wiki.powergui.org/index.php/Set-QADUser
.LINKS
	http://wiki.powergui.org/index.php/Remove-QADMemberOf
.LINKS
	http://technet.microsoft.com/en-us/library/hh849698.aspx
.NOTES
   	Author: 	Kavanagh, John J.
   	Created: 	01.13.2012
   	01.13.2012: Remove comment block designators on lines 21 and 26 to enable 
				code to update user account. -no longer valid
	01.13.2012:	Unable to test Add/Remove with QADMEMBEROF - Access Denied
	01.13.2012:	Line 41 will need to be tweaked if script will be run more 
				than once a day.
	01.24.2012:	Applied what appears to be the naming convention of the new
				user profile folder with test-path. Not sure if this script
				will be responsible for the creation of the folder as well.
	01.26.2012:	Added logic for creating paths based on user's AllUsers
				group membership.
	01.26.2012:	TODO - Add set-qaduser within switch statement, to includue 
				logonscript.
	02.15.2012:	TODO - Add file move from XP home to Win7 home
	02.20.2012: IE7 group add moved to begining of function and not in the 
				Switch statement
	02.24.2012: Tweaked logfile to account for multiple migrations per day
	02.24.2012: Updated user update and computer move processes
	02.27.2012: Updated reference to GLG-Win7_Runme to OSD-Win7_Runme
	02.27.2012: Updated new groups replacing System with Systems
	02.29.2012: Added process to start file copy as job
	02.29.2012: Set transcript to d:\logs
    03.10.2012: Running as scheduled task causes file copy jobs to end when
                scheduled task completes.  Need to tweak wait-job.
	03.13.2012:	Added Touch and implemented touch to create a file to act as
				placeholder for NAS cleanup routine.
	03.14.2012:	Tweaked computer OU move to eliminate issue where multiple objects
				are returned.
	03.22.2012: Added copy-userdocs function to handle async file copies, modified
				wait routine removing asterisk from wait-job.
	03.22.2012: TODO: Convert all Quest AD calls to use Native Active Directory module.
	03.22.2012: Split set-qaduser into individual commands and added pauses.
	03.22.2012: Added conect-qadservice to insure specific connection to INFONET
	03.26.2012: TODO: finalize process for AD group cleanup, removing during this script
					  causes issues with computer build.
	03.26.2012: TODO: move the set-qaduser statements to a single block after the switch
					  statement instead of in each switch match.
	03.27.2012: Parametized/Splatted Start-Job call.
	03.27.2012: Adding if statements for the set-qaduser functions.
	03.27.2012: Formalized the Remove-QADGroupMember with Identity and Member.
	03.27.2012: Formalized the computer OU move to report success/failure.
	03.27.2012: Added Regions to allow collapse of sections.
	04.16.2012: Update group update with new Office 2010 AD group names.
	04.17.2012: Added while loop in an effort to make script run until all copy
				jobs complete, previous wait-job was not preventing scheduled
				task from immediately closing.
	04.17.2012: TODO: Add directory (gci) comparison for xp homefolder to win7
					  homefolder and include in log.
#>
# # # Start of Functions # # #
#Region Functions
function touch {  
param($path) # Passes command line argument as variable
    New-Item -ItemType file -Path $path -Name "OSDW7.txt"
} # end of touch function
function copy-userdocs {
Param(
	[parameter(Mandatory=$true,
	ValueFromPipeline=$true)]
	[string]$srcpath,
	[parameter(Mandatory=$true,
	ValueFromPipeline=$true)]
	[string]$destpath,
	[string]$jname
)
	$logfile="d:\Logs\$($jname).txt" 
	$cmdtext="copy-Item -Path $srcpath -Destination $destpath -Recurse -Force -ea 'SilentlyContinue' -Container -PassThru | select FullName | out-file $logfile -append"
	$sb=[scriptblock]::Create($cmdtext)
	"Starting copy of files for $jname at $(get-date -f g)" | out-file $logifle -append
	$jobdat = @{
		Name = $jname
		ScriptBlock = $sb
	}
	start-Job $jobdat
	"File copy $($jname) started"
} # end of copy-userdocs
function update-win7fields {
param ($usrname)
$curusr = Get-QADUser $usrname 
"Current properties for $($curusr.Name)"
# Record current settings
$curusr.Name
$curusr.HomeDrive
$curusr.HomeDirectory
$curusr.ProfilePath
# For All Users
If ($curusr | Set-QADUser -LogonScript "Win7.cmd"){"Set LogonScript for $($curusr.name)"}
Else {"Unable to set LogonScript for $($curusr.name)"}
# Generate variable to be used for setting user's new profile path
$targetgrp = ((get-qaduser $curusr | get-qadmemberof -Name *AllUsers).Name -split '-')[0]
# Generate variable to be used for setting user's new profile path
if ($targetgrp.length -eq 0){
	$w7home = "No Valid AllUsers membership"
	$w7profile = "No Valid AllUsers membership"
} # end of processing where user not member of allusers group
else { 
# Process based on targetgrp value to generate new paths
switch -wildcard ($targetgrp)
	{
		"CH1"	{
				$w7home = "\\CH1FP01\Home$\$($curusr.LogonName)\My Documents"
				if (Test-Path $w7home){
					"Copying data from existing home folder to $($w7home)"
					copy-Item -Path "$($curusr.HomeDirectory)\*" -Destination $w7home -Force -Recurse -PassThru |`
						select Name
					"Data copied, now setting AD Properties" 
					$curusr | set-QADUser -HomeDrive "H:"
					$curusr | Set-QadUser -HomeDirectory $w7home
				}
				else {"Unable to find $($w7home); please investigate"}
				# Set Profile related settings
				$w7profile = "\\ch1FP01\Profile$\$($curusr.LogonName)" 
				If ($curusr | Set-QadUser -ProfilePath $w7Profile){"User Profile path set."}
				Else {"Unable to find $($w7Profile) please investigate"}
				} # End CH1
		"IOM"	{
				$w7home = "\\UK1FP01\Home$\$($curusr.LogonName)\My Documents"
				if (Test-Path $w7home){
					"Copying data from existing home folder to $($w7home)"
					copy-Item -Path "$($curusr.HomeDirectory)\*" -Destination $w7home -Force -Recurse -PassThru |`
						select Name
					"Data copied, now setting AD Properties" 
					$curusr | set-QADUser -HomeDrive "H:"
					$curusr | Set-QadUser -HomeDirectory $w7home
				}
				else {"Unable to find $($w7home); please investigate"}
				# Set Profile related settings
				$w7profile = "\\UK1FP01\Profile$\$($curusr.LogonName)" 
				If ($curusr | Set-QadUser -ProfilePath $w7Profile){"User Profile path set."}
				Else {"Unable to find $($w7Profile) please investigate"}
				} # End IOM
		"NL1"	{
				$w7home = "\\NL1FP01\Home$\$($curusr.LogonName)\My Documents"
				if (Test-Path $w7home){
					"Copying data from existing home folder to $($w7home)"
					copy-Item -Path "$($curusr.HomeDirectory)\*" -Destination $w7home -Force -Recurse -PassThru |`
						select Name
					"Data copied, now setting AD Properties" 
					$curusr | set-QADUser -HomeDrive "H:"
					$curusr | Set-QadUser -HomeDirectory $w7home
				}
				else {"Unable to find $($w7home); please investigate"}
				# Set Profile related settings
				$w7profile = "\\NL1FP01\Profile$\$($curusr.LogonName)"
				If ($curusr | Set-QadUser -ProfilePath $w7Profile){"User Profile path set."}
				Else {"Unable to find $($w7Profile) please investigate"}
				} # End NL1
		"CN1"	{
				$w7home = "\\CN1FP01\Home$\$($curusr.LogonName)\My Documents"
				if (Test-Path $w7home){
					"Copying data from existing home folder to $($w7home)"
					copy-Item -Path "$($curusr.HomeDirectory)\*" -Destination $w7home -Force -Recurse -PassThru |`
						select Name
					"Data copied, now setting AD Properties" 
					$curusr | set-QADUser -HomeDrive "H:"
					$curusr | Set-QadUser -HomeDirectory $w7home
				}
				else {"Unable to find $($w7home); please investigate"}
				# Set Profile related settings
				$w7profile = "\\CN1FP01\Profile$\$($curusr.LogonName)" 
				If ($curusr | Set-QadUser -ProfilePath $w7Profile){"User Profile path set."}
				Else {"Unable to find $($w7Profile) please investigate"}
				} # End CN1
		"OHR"	{
				$w7home = "\\OHRFP01\Home$\$($curusr.LogonName)\My Documents"
				if (Test-Path $w7home){
					"Copying data from existing home folder to $($w7home)"
					copy-Item -Path "$($curusr.HomeDirectory)\*" -Destination $w7home -Force -Recurse -PassThru |`
						select Name
					"Data copied, now setting AD Properties" 
					$curusr | set-QADUser -HomeDrive "H:"
					$curusr | Set-QadUser -HomeDirectory $w7home
				}
				else {"Unable to find $($w7home); please investigate"}
				# Set Profile related settings
				$w7profile = "\\OHRFP01\Profile$\$($curusr.LogonName)" 
				If ($curusr | Set-QadUser -ProfilePath $w7Profile){"User Profile path set."}
				Else {"Unable to find $($w7Profile) please investigate"}
				} # End OHR
		"OHS"	{
				$w7home = "\\OHSFP01\Home$\$($curusr.LogonName)\My Documents"
				if (Test-Path $w7home){
					"Copying data from existing home folder to $($w7home)"
					copy-Item -Path "$($curusr.HomeDirectory)\*" -Destination $w7home -Force -Recurse -PassThru |`
						select Name
					"Data copied, now setting AD Properties" 
					$curusr | set-QADUser -HomeDrive "H:"
					$curusr | Set-QadUser -HomeDirectory $w7home
				}
				else {"Unable to find $($w7home); please investigate"}
				# Set Profile related settings
				$w7profile = "\\OHSFP01\Profile$\$($curusr.LogonName)" 
				If ($curusr | Set-QadUser -ProfilePath $w7Profile){"User Profile path set."}
				Else {"Unable to find $($w7Profile) please investigate"}
				} # End OHS
		"HY*"	{
				$w7home = "\\OHSFP01\Home$\$($curusr.LogonName)\My Documents"
				if (Test-Path $w7home){
					"Copying data from existing home folder to $($w7home)"
					copy-Item -Path "$($curusr.HomeDirectory)\*" -Destination $w7home -Force -Recurse -PassThru |`
						select Name
					"Data copied, now setting AD Properties" 
					$curusr | set-QADUser -HomeDrive "H:"
					$curusr | Set-QadUser -HomeDirectory $w7home
				}
				else {"Unable to find $($w7home); please investigate"}
				# Set Profile related settings
				$w7profile = "\\OHSFP01\Profile$\$($curusr.LogonName)" 
				If ($curusr | Set-QadUser -ProfilePath $w7Profile){"User Profile path set."}
				Else {"Unable to find $($w7Profile); please investigate"}
				} # End HY
		"HLD"	{
				$w7home = "\\OHHFP01\Home$\$($curusr.LogonName)\My Documents"
				if (Test-Path $w7home){
					"Copying data from existing home folder to $($w7home)"
					copy-Item -Path "$($curusr.HomeDirectory)\*" -Destination $w7home -Force -Recurse -PassThru |`
						select Name
					"Data copied, now setting AD Properties" 
					$curusr | set-QADUser -HomeDrive "H:"
					$curusr | Set-QadUser -HomeDirectory $w7home
				}
				else {"Unable to find $($w7home); please investigate"}
				# Set Profile related settings
				$w7profile = "\\OHHFP01\Profile$\$($curusr.LogonName)" 
				If ($curusr | Set-QadUser -ProfilePath $w7Profile){"User Profile path set."}
				Else {"Unable to find $($w7Profile) please investigate"}
				} # End HLD
		"WHI"	{
				$w7home = "\\OHHFP01\Home$\$($curusr.LogonName)\My Documents"
				if (Test-Path $w7home){
					"Copying data from existing home folder to $($w7home)"
					copy-Item -Path "$($curusr.HomeDirectory)\*" -Destination $w7home -Force -Recurse -PassThru |`
						select Name
					"Data copied, now setting AD Properties" 
					$curusr | set-QADUser -HomeDrive "H:"
					$curusr | Set-QadUser -HomeDirectory $w7home
				}
				else {"Unable to find $($w7home); please investigate"}
				# Set Profile related settings
				$w7profile = "\\OHHFP01\Profile$\$($curusr.LogonName)" 
				If ($curusr | Set-QadUser -ProfilePath $w7Profile){"User Profile path set."}
				Else {"Unable to find $($w7Profile) please investigate"}
				} # End WHI
		"CA1"	{
				$w7home = "\\CA1FP01\Home$\$($curusr.LogonName)\My Documents"
				if (Test-Path $w7home){
					"Copying data from existing home folder to $($w7home)"
					copy-Item -Path "$($curusr.HomeDirectory)\*" -Destination $w7home -Force -Recurse -PassThru |`
						select Name
					"Data copied, now setting AD Properties" 
					$curusr | set-QADUser -HomeDrive "H:"
					$curusr | Set-QadUser -HomeDirectory $w7home
				}
				else {"Unable to find $($w7home); please investigate"}
				# Set Profile related settings
				$w7profile = "\\CA1FP01\Profile$\$($curusr.LogonName)" 
				If ($curusr | Set-QadUser -ProfilePath $w7Profile){"User Profile path set."}
				Else {"Unable to find $($w7Profile) please investigate"}
				} # End CA1
		# All exceptions processed now apply standard pattern
		Default	{
				#Process items regarding the Home Folder
				$w7home = "\\IS1NAP02\Home$\$($targetgrp)\$($curusr.LogonName)\My Documents"
				$w7profile = "\\IS1NAP02\Profile$\$($targetgrp)\$($curusr.LogonName)" 
				if (Test-Path $w7home){
					"Copying data from existing home folder to $($w7home)"
					$jobName = $curusr.LogonName
					$curdocs =  "$($curusr.HomeDirectory)\*"
					# Call function to copy user's home folder to new location
					copy-userdocs $curdocs $w7home $($curusr.LogonName)
					"Data copy started check logs folder to verify, now setting AD Properties" 
					"Setting HomeDrive to H:"
					if ($curusr | set-QADUser -HomeDrive "H:" ){"Set HomeDrive to H: for $($curusr.name)"}
					Else {"Unable to set Homedrive for $($curusr.name)"}
					start-Sleep -Seconds 2
					"Setting HomeDirectory to $($w7home)"
					if ($curusr | set-QADUser -HomeDirectory $w7home){"Set HomeDirectory to $($w7home) for $($curusr.name)"}
					Else {"Unable to set HomeDirectory to $($w7home) for $($curusr.name)!"}
					start-Sleep -Seconds 2
					"Setting ProfilePath to $($w7profile)"
					If ($curusr | set-QADUser -ProfilePath $w7profile){"Set ProfilePath to $($w7profile) for $($curusr.name)"}
					Else {"Unable to set ProfilePath to $w7profile for $($curusr.name)!"}
					start-Sleep -Seconds 2
				}
				else {"Unable to find $($w7home); please investigate"}
		} # End default switch loop
		
	}
}
$updusr=Get-QADUser $curusr.LogonName 
# Record the settings after update
"-" * 38
"New Settings for $($updusr.Name)"
"Home Drive: $($updusr.HomeDrive)"
"Home Directory: $($updusr.HomeDirectory)"
"Profile Path: $($updusr.ProfilePath)"
"Logon Script: $($updusr.LogonScript)"
"Verify user settings for OS Migration"
# Remove user from source group
Remove-QADMemberOf $updusr -Group "OSD-Win7 RunMe"
} # end of user AD properties function
function update_gpogrps($uname){
# Add user to group that applies to all users
"Adding $($uname.name) to GPO-W7-Internet Explorer Primary group."
Add-QADGroupMember "INFONET\GPO-W7-Internet Explorer Primary" $uname | out-null
# Determine which XP Group Membership nees to be migrated to Win7 equivelant
$grplist = get-qadmemberof $uname | ? {$_.Name -like 'GPO*'}
foreach ($grp in $grplist){
	switch ($grp.name)
	{
	"GPO-Power-User-Desktop"		{
										"Adding $($uname) to GPO-W7-Domain User Desktop group."
										Add-QADGroupMember INFONET\"GPO-W7-Domain User Desktop" $uname | out-null
										"Remove from XP Specific GPO-Power-User-Desktop"
										Remove-QADGroupMember -Identity INFONET\"GPO-Power-User-Desktop" -Member $uname | out-null
									}
	"GPO-Power-User-Laptop"			{
										"Adding $($uname) to GPO-W7-Domain User Laptop group."
										Add-QADGroupMember INFONET\"GPO-W7-Domain User Laptop" $uname | out-null
										"Remove from XP Specific GPO-Power-User-Laptop"
										Remove-QADGroupMember -Identity INFONET\"GPO-Power-User-Laptop" -Member $uname | out-null
									}
	"GPO-Dev-Power-User-Desktop"	{
										"Adding $($uname) to GPO-W7-System Manager-Desktop group."
										Add-QADGroupMember INFONET\"GPO-W7-System Manager-Desktop" $uname | out-null
										"Remove from XP Specific GPO-Dev-Power-User-Desktop"
										Remove-QADGroupMember -Identity INFONET\"GPO-Dev-Power-User-Desktop" -Member $uname | out-null
									}
	"GPO-Dev-Power-User-Laptop"		{
										"Adding $($uname) to GPO-W7-System Manager-Laptop group."
										Add-QADGroupMember INFONET\"GPO-W7-Systems Manager-Laptop" $uname | out-null
										"Remove from XP Specific GPO-Dev-Power-User-Desktop"
										Remove-QADGroupMember -Identity INFONET\"GPO-Dev-Power-User-Laptop" -Member $uname | out-null
									}
	"GPO-System Manager-Desktop"	{
										"Adding $($uname) to GPO-W7-Systems Manager-Desktop group."
										Add-QADGroupMember INFONET\"GPO-W7-Systems Manager-Desktop" $uname | out-null
										"Remove from XP Specific GPO-System Manager-Desktop"
										Remove-QADGroupMember -Identity INFONET\"GPO-System Manager-Desktop" -Member $uname | out-null
									}
	"GPO-System Manager-Laptop"		{
										"Adding $($uname) to GPO-W7-System Manager-Laptop group."
										Add-QADGroupMember INFONET\"GPO-W7-Systems Manager-Laptop" $uname | out-null
										"Remove from XP Specific GPO-System Manager-Laptop"
										Remove-QADGroupMember -Identity INFONET\"GPO-System Manager-Laptop" -Member $uname | out-null
									}
	"GPO-OFFICE-2003"				{
										"Adding $($uname) to GPO-W7-MS OFFICE 2010-Desktop group."
										Add-QADGroupMember INFONET\"GPO-W7-MS Office 2010" $uname | out-null
										"Remove from XP Specific GPO-OFFICE-2003"
										Remove-QADGroupMember -Identity INFONET\"GPO-OFFICE-2003" -Member $uname | out-null
									}
	"GPO-OFFICE-2003-CACHED"		{
										"Adding $($uname) to GPO-W7-MS OFFICE 2010-Laptop group."
										Add-QADGroupMember INFONET\"GPO-W7-MS Office 2010-CACHED" $uname | out-Null
										"Remove from XP Specific GPO-OFFICE-2003-CACHED"
										Remove-QADGroupMember -Identity INFONET\"GPO-OFFICE-2003-CACHED" -Member $uname | out-Null
									}
	} # End Switch
}
} # end of group update function
function mail-process($scrstat) {
$msg=@{
	from = 'john.kavanagh@swagelok.com'
	To = "#Win7DeploymentTeam@Swagelok.Com"
	Subj = "Win7 Migration User Update - $($scrstat)"
	Body="Userupdate Script $scrstat at $(get-date -f D)"
	smtpserver='smtp.swagelok.com'
}
send-mailmessage @msg
} # End of email function
#EndRegion
# # # End of functions # # #
# Create a log of script actions
Start-Transcript -Path "d:\logs\$((get-date -format 'MMddyyyyhhmm'))-MigrationScriptLog.txt" -Force 
#
# Script Start
#
mail-process "Started"
# Verify the Quest Snapin is loaded, loaded if it is not running
# connects directly to INFONET 
if (get-pssnapin quest.activeroles.admanagement -ea SilentlyContinue){ connect-qadservice "INFONET" | out-null}
else { "Script requires Quest AD Snapin" 
		Add-PSSnapin quest*
		Connect-QADService "INFONET" | out-null
}
# Process users 
#Region Users
$sourcegroup="OSD-Win7 RunMe" # need to change sourc
if ($src=get-qadgroup $sourcegroup){
	"Will process $($src.members.count) for Win7 Migration"
	# Build user list from group
	$w7users 	= $src | get-qadgroupmember
	"Users slated for Win7 account settings: "
	$w7users | sort name | select Name,LogonName
	$ljob = ($w7users | Select -Last 1 ).LogonName
	# $w7machines = $src | Get-QADGroupMember -Type Computer
	foreach ($w7user in $w7users){
		"Processing $($w7user.Name)"
		# Call update function for each user in the source group
		update-win7fields $w7user.logonname
		# Add placeholder for storage cleanup
		touch "\\is1nap02\users\$($w7user.LogonName)\My Documents"
		touch "\\is1nap02\Profiles\$($w7user.LogonName)"
		# Modify user group membership to activate Win7 appropriate settings
		update_gpogrps $w7user
		# Remove user from the Migration list AD Group
		# Remove-QADMemberof $w7usr -Group "INFONET\$($sourcegroup)"
		# Add user to group for monitoring for post migration cleanup
		Add-QADGroupMember "INFONET\OSD-Win7 FollowUp" $w7usr
	} # End processing user list
} # End if RunMe group exists
else {"Error executing script against empty or non-existent group"}
#EndRegion

# Test code to handle keeping file copy jobs running until complete
get-job  | out-File "d:\logs\$((get-date -format 'MMddyyyyhhmm'))-FileCopyJobs.txt"
start-Sleep -Seconds 180
# Monitor background jobs
While (get-job -state running){
	get-job -state Running | select Name, Command
	start-Sleep -Seconds 5
}
get-job | receive-job -Keep
mail-process "Completed"
stop-transcript # Close transcript to finalize log file of script activity
$error | out-File d:\logs\usrupdate.errs
# SIG # Begin signature block
# MIIEFQYJKoZIhvcNAQcCoIIEBjCCBAICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqxH3A6BApIKLehVTimyRwOil
# 5OigggItMIICKTCCAZKgAwIBAgIQrOfUqrQ+kKREeKyDkz+mwDANBgkqhkiG9w0B
# AQUFADAeMRwwGgYDVQQDExNzcnZqa2F2YSAtIFN3YWdlbG9rMB4XDTExMDEwMTA1
# MDAwMFoXDTE3MDEwMTA1MDAwMFowHjEcMBoGA1UEAxMTc3J2amthdmEgLSBTd2Fn
# ZWxvazCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAx46O2ULyLzX+7mnFZIsT
# 3NKk2WT8+arh4lm/DE3p1+j1jFD7t5F3Xq+5Wp3iOnjWxrfB5n5hkxol5jPp0jTV
# Gt+GCYd3B1K8K0ot3eq5t3EzZY25hJV5RP8nLux2PZ4Zv5XtwOxumdzgBcw4TNDK
# NmlVl4J1WBI2rQZdHpAju2sCAwEAAaNoMGYwEwYDVR0lBAwwCgYIKwYBBQUHAwMw
# TwYDVR0BBEgwRoAQ4S1RzNj3oK1AFF68rJJk7KEgMB4xHDAaBgNVBAMTE3Nydmpr
# YXZhIC0gU3dhZ2Vsb2uCEKzn1Kq0PpCkRHisg5M/psAwDQYJKoZIhvcNAQEFBQAD
# gYEAJ3RLTpu5MSHZ5v6S3ryk9/0tBtrr+8vyJvttZKONJ/0bavOiydSLFrXe6dIq
# 7rkZX0ync00P41J/HyCziQ/06RDCb3FAXj7wt62/FIoIGKB7vlHQZ2ZwcoRx309q
# sm8vYDRD7mfVmqB08OrTwihVnyy948OcYsJFgKrX4DLn8lUxggFSMIIBTgIBATAy
# MB4xHDAaBgNVBAMTE3NydmprYXZhIC0gU3dhZ2Vsb2sCEKzn1Kq0PpCkRHisg5M/
# psAwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZI
# hvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
# ARUwIwYJKoZIhvcNAQkEMRYEFHvpbgqHNanU0i+2yrNvot9ynYoBMA0GCSqGSIb3
# DQEBAQUABIGAem9Y+7NNtnNvi/Ewa4RkBby8VGJRNG47DnGYEt7iyQY+rzbhzjco
# GMGLNJKeAFA1P0WQCKR7WhiISw9/37h1ZjWJPZjtPnfnfTLi3sXfoDCFZBpKFYJX
# cvB/T94Zyn2D7tCria63+Zl4UUTrgJRfANGOkLRRy6j8v/cQcF7EKbw=
# SIG # End signature block
