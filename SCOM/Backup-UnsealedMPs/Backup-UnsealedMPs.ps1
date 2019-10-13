#=================================================================================================
# AUTHOR:  Tao Yang 
# DATE:    22/06/2011
# Version: 1.0
# Comment: Export and backup all unsealed MPs
#=================================================================================================
Function Delete-OldBackup ($Destination, $daysToKeep)
{
	$ChildItems += Get-ChildItem $Destination | Where-Object {$_.PSIsContainer -eq $true}
		Foreach ($item in $ChildItems)
		{
			$fullPath = $item.FullName
			if ($item.CreationTime -le $date.adddays(-$DaysToKeep))
			{
				Write-Host " -Deleting $fullPath`..." -ForegroundColor Yellow
				Remove-Item -Path $fullPath -Recurse -Force -Confirm:$false
			}
		}
}
#Define backup locations and retention
$BackupRoot = "D:\SCOM Backups\MP Backups"
$remoteLocation = "\\SCOM02\D$\SCOMBackups\MPBackups"
$daysToKeep = 3

$thisScript = Split-Path $myInvocation.MyCommand.Path -Leaf
$scriptRoot = Split-Path(Resolve-Path $myInvocation.MyCommand.Path)
$robocopyLoc = Join-Path $scriptRoot "robocopy.exe"

#Robocopy switches
$retry = "r:100"
$wait = "w:5"

##Initiate SCOM PSSnapin
$RMS = $env:COMPUTERNAME
$date = Get-Date
$BackupSubDir = "$($date.day)-$($date.month)-$($date.year)"
$BackupLocation = Join-Path $BackupRoot $BackupSubDir

if (!(Test-Path $BackupLocation))
{
	Write-Host "Creating $BackupLocation directory..." -ForegroundColor Yellow
	New-Item -type directory -Path $BackupLocation | Out-Null
}

#adding SCOM PSSnapin
Write-Host "Connecting to Root Management Server $RMS..." -ForegroundColor Yellow
if ((Get-PSSnapin | where-Object { $_.Name -eq 'Microsoft.EnterpriseManagement.OperationsManager.Client' }) -eq $null)
{ 
	Add-PSSnapin Microsoft.EnterpriseManagement.OperationsManager.Client -ErrorAction SilentlyContinue -ErrorVariable Err
}
if ((Get-PSDrive | where-Object { $_.Name -eq 'Monitoring' }) -eq $null)
{
	New-PSDrive -Name:Monitoring -PSProvider:OperationsManagerMonitoring -Root:\ -ErrorAction SilentlyContinue -ErrorVariable Err | Out-Null
}

#Connect to RMS
Set-Location "OperationsManagerMonitoring::"
new-managementGroupConnection -ConnectionString:$RMS | Out-Null
Set-Location Monitoring:\$RMS


#Get all unsealed MPs
Write-Host "Getting Unsealed Management Packs..." -ForegroundColor Yellow
$UnsealedMPs = Get-ManagementPack | Where-Object {$_.Sealed -eq $false}

Write-Host "Exporting Unsealed management packs to $BackupLocation..." -ForegroundColor Yellow
Foreach ($MP in $UnsealedMPs)
{
	Export-Managementpack -managementpack $MP -Path $BackupLocation
}

#remove old backups
Write-Host "Deleting previous backups older than $DaystoKeep days.." -ForegroundColor Yellow
	
	#Delete from local computer
	Delete-OldBackup $BackupRoot $daysToKeep
	
Write-Host "Copying Unsealed management packs to $remoteLocation..." -ForegroundColor Yellow
robocopy.exe $BackupRoot $remoteLocation /e /zb /copy:dat /tbd /$retry /$wait /v /ts /fp /tee /purge

Write-Host "Done!" -ForegroundColor Yellow