$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication  Basic -AllowRedirection
Import-PSSession $Session

$TeamsStats = Get-UnifiedGroup | Get-MailboxFolderStatistics  | ? {$_.Name -eq “Team Chat”}

#Get Teams With No Chat Activity for Last 90 Days

$TeamsStats | ? {$_.LastModifiedTime -lt (get-date).AddDays(-90)} | Format-Table Identity, Name, ItemsInFolder, LastModified*, creationtime


#Get Teams Created in the Last 30 Days

$TeamsStats | ? {$_.CreationTime -gt (get-date).AddDays(-30)} | Format-Table Identity, Name, ItemsInFolder, LastModified*, CreationTime

