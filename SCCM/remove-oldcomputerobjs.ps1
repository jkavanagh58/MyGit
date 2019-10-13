# Environment setup
# Import the ActiveDirectory module to enable the Get-ADComputer CmdLet
Import-Module ActiveDirectory

$SCCMServer = "dmz1sms01"
$sitename = "DZ1"
$old = (Get-Date).AddDays(-45) # The threshold for what we consider to be old (current set as 45 days)

# Find the computers in Active Directory which are "old"
$oldComputers = Get-ADComputer -Filter {PasswordLastSet -le $old} -Properties *

ForEach ($oldComputer in $oldComputers) {
	# Select the computer(s)
	$computername = $oldComputer.name 

	# Get the resourceID from SCCM
	$resID = Get-WmiObject -computername $SCCMServer -query "select resourceID from sms_r_system 	where name like `'$computername`'" -Namespace "root\sms\site_$sitename"
	$computerID = $resID.ResourceID

	if ($resID.ResourceId -eq $null) {
		$msgboxValue = "No SCCM record for that computer"
		}
	else
		{
    		$comp = [wmi]"\\$SCCMServer\root\sms\site_$($sitename):sms_r_system.resourceID=$($resID.ResourceId)" 

    		# Output to screen
		Write-Host "$computername with resourceID $computerID will be deleted"

		# Delete the computer account
        # Remove comment from below line to actually delete object
    	# $comp.psbase.delete()
	}
}