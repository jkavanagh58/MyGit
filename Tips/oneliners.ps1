<#
	 Collection of oneliners for easy reference

	.NOTES
		07.22.2018 JJK:	Using regions to help code folding if using ISE
#>
<#
	Powershell Operations
	This is a Collection specific to PowerShell general operations
#>
#region Security
# List all certificates issued by Wegmans that will expire in 60 days
Get-ChildItem -Path Cert: -ExpiringInDays 150 -Recurse | Where Issuer -like "*Wegmans*" | select-Object -Property Subject, NotAfter
#endregion
#region  PoshOps

# Install a Module(s) from PSGallery - these are key if you are using VSCode
Install-Package -Name editorse* -Scope AllUsers -Confirm:$false -Force
# Install a software via chocolatey
install-package -Name sysinternals -ProviderName Chocolatey -Verbose
# List installed Chocolatey Packages
Get-Package -ProviderName Chocolatey
# Use PowerShellGet to update module(s)
update-module -Name dbatools, Pester -confirm:$false -Force -Verbose
# Use PowerShellGet to update all modules (applies to all PSGallery Modules)
update-module -confirm:$false -Verbose -Force
# Find Compatible
find-module -Tag PSEdition_Desktop, PSEdition_Core -Repository PSGallery | Sort-Object -Property Name
# Install PowerShell Core
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI -Quiet"

#endregion
<#
	File Operations
	This is a Collection specific to File Object operations
#>
#region  FileOps

# Mapping a network drive, replacing net use
New-PSDrive -Name S -PSProvider FileSystem -Root "<UNC Path>" -Persist

# Download a script and it won't work because it isn't signed, unblock it
# Just a quick example
Get-ChildItem *.zip -Path $env:USERPROFILE\Downloads | Unblock-File -Verbose

# Might not be practical but a great example of a one-liner as well as using inline methods
(get-childitem *.tmp -Path $env:TEMP).Where{ ((Get-date) - $_.LastWriteTime).TotalDays -gt 7 }.ForEach{ Remove-Item -Path $_.FullName }

#endregion
<#
	Network Operations
	This is a Collection specific to Network operations
#>
#region NetOps

# Flush the DNS Cache
Clear-DnsClientCache -Force
# Get report of your current DNS Cache - added an example of filtering based on record type
Get-DnsClientCache -RecordType A
# Get report of your current DNS Cache - this one is in here because you need to check the output type
# if you pipe the cmdlet to Get-Member you will see not just text
# Check Get-DnsClientCache | get-member -Name Section
<#
		Name    MemberType Definition
		----    ---------- ----------
		Section Property   byte Section {get;}
	#>
(Get-DnsClientCache).Where{ $_.Section -ne 1 }
# Get the IP V4 Address for Physical adapters that are connected
(get-netadapter -Physical).Where{ $_.Status -eq 'up' } | % { (Get-NetIPAddress -InterfaceIndex $_.ifIndex).IPv4Address }
# Netstat
Get-NetTCPConnection
# Netstat show connections to remote
Get-NetTCPConnection -RemoteAddress (Resolve-DNS <hostname>).IPAddress

#endregion
<#
	ActiveDirectory Operations
	This is a Collection specific to AD operations
#>
#region ADOps
# Get Active Servers Only
get-adcomputer -Filter { OperatingSystem -like "*Windows Server*" } -Properties PasswordLastSet |
Where-Object { ((get-date) - $_.PasswordLastSet).TotalDays -lt 31 } |
Select-Object -Property Name, PasswordLastSet, @{N = "DaysElapsed"; e = { ((get-date) - $_.PasswordLastSet).TotalDays } } |
sort-object -Property Name

#endregion
<#
	ScheduleTasks Operations
	This is a Collection specific to Scheduled Tasks
#>
#region SchTasksOps
schtasks.exe /query /V /FO CSV | convertfrom-csv |
where 'Run As User' -like "*techadminjxk*" |
Select-Object -Property TaskName, 'Schedule Type' |
Out-Gridview -Title "Scheduled Tasks Audit"
#endregion
#region System Operation
<#
	System Operations
	This is a collection of CLI management of a Systems Operations
#>
# Yes kill that ISE session
get-process -Name Powershell_ISE | get-member -MemberType Method
#endregion