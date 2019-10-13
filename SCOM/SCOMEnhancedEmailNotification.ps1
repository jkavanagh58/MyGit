#=====================================================================================================
# AUTHOR:	J. Greg Mackinnon, Adapted from 1.1 release by Tao Yang 
# DATE:		2013-05-21
# Name:		SCOMEnhancedEmailNotification.PS1
# Version:	3.0
# COMMENT:	SCOM Enhanced Email notification which includes detailed alert information
# Update:	2.0 - 2012-06-30	- Major revision for compatibility with SCOM 2012
#								- Cmdlets updated to use 2012 names
#								- "Notified" Resolution Status logic removed
#								- Snapin Loading and PSDrive Mappings removed (replaced with Module load)
#								- HTML Email reformatted for readability
#								- Added '-format' parameter to allow for alphanumeric pager support
#								- Added '-diag' boolean parameter to create options AlertID-based diagnostic logs
# Update:   2.2 - 2013-05-16    - Added logic to update "CustomField1" alert data to reflect that notification has been sent for new alerts.
#								- Added logic to update "CustomField2" alert data to reflect the repeat count for new alert notification sends.
#								- Added support for specifying alerts with resolution state "acknowledged"
#                               - Did some minor adjustments to improve execution time and reduce memory overhead.
# Update:	3.0 - 2013-05-20	- Updated to reduce volume of PowerShell instance spawned by SCOM.  Added "mailTo" and "pageTo" paramerters to allow sending of both short
#                                         and long messages from a single script instance.
#								- Converted portions of script to subroutine-like functions to allow repetition (buildHeaders, buildPage, buildMail)
#								- Restored "Notified" resolution state logic.
#								- Renamed several variables for my own sanity.
#								- Added article lookup updates from Tao Yang 2.0 script.
# Usage:	.\SCOMEnhancedEmailNotification.ps1 -alertID xxxxx -mailTo @('John Doe;jdoe@mail.com','Richard Roe;rroe@provider.net') -pageTo @('Team Pager;teampage@page.provider.com')
#=====================================================================================================
#In OpsMgr 2012, the AlertID parameter passed in is '$Data/Context/DataItem/AlertId$' (single quote)
#Quotation marks are required otherwise the AlertID parameter will not be treated as a string.
param(
	[string]$alertID = $(throw 'A valid, quote-delimited, SCOM AlertID must be provided for -AlertID.'),
	[string[]]$mailto,
	[string[]]$pageto,
	[switch]$diag
)
Set-PSDebug -Strict

#### Setup Error Handling: ####
$error.clear()
#$erroractionpreference = "SilentlyContinue"
$erroractionpreference = "Inquire"

#### Setup local option variables: ####
## Logging: 
#Remove '$alertID' from the following two log file names to prevent the drive from filling up with diag logs:
$errorLogFile = 'C:\local\logs\SCOMNotifyErr-' + $alertID + '.log'
$diagLogFile = 'C:\local\logs\SCOMNotifyDiag-' + $alertID + '.log'
#$errorLogFile = 'C:\local\logs\SCOMNotifyErr.log'
#$diagLogFile = 'C:\local\logs\SCOMNotifyDiag.log'
## Mail: 
$SMTPHost = "smtp.uvm.edu"
$SMTPPort = 25
$Sender = New-Object System.Net.Mail.MailAddress("OpsMgr@lifeboat.campus.ad.uvm.edu", "Lifeboat OpsMgr Notification")
#If error occured while excuting the script, the recipient for error notification email.
$ErrRecipient = New-Object System.Net.Mail.MailAddress("saa-ad@uvm.edu", "SAA Windows Administration Team")
##Set Culture Info (for knowledgebase article language selection):
$cultureInfo = [System.Globalization.CultureInfo]'en-US'
##Get the FQDN of the local computer (where the script is run)...
$RMS = $env:computername

#### Initialize Global Variables and Objects: ####
## Mail Message Object:
[string] $threadID = ''
$SMTPClient = New-Object System.Net.Mail.smtpClient
$SMTPClient.host = $SMTPHost
$SMTPClient.port = $SMTPPort
##Load SCOM PS Module
if ((get-module | ? {$_.name -eq 'OperationsManager'}) -eq $null) {
	Import-Module OperationsManager -ErrorAction SilentlyContinue -ErrorVariable Err | Out-Null
}
## Management Group Object:
$mg = get-SCOMManagementGroup
##Get Web Console URL
$WebConsoleBaseURL = (get-scomwebaddresssetting | Select-Object -Property WebConsoleUrl).webconsoleurl
#### End Initialize ####


#### Begin Parse Input Parameters: ####
##Get recipients names and email addresses from "-to" array parameter: ##
if ((!$mailTo) -and (!$pageTo)) {
	write-host "An array of name/email address pairs must be provided in either the -mailTo or -pageTo parameter, in the format `@(`'me;my@mail.com`',`'you;you@mail.net`')"
	exit
}
$mailRecips = @()
Foreach ($item in $mailTo) {
	$to = New-Object psobject
	$name = ($item.split(";"))[0]
	$email = ($item.split(";"))[1]
	Add-Member -InputObject $to -MemberType NoteProperty -Name Name -Value $name
	Add-Member -InputObject $to -MemberType NoteProperty -Name Email -Value $email
	$mailRecips += $to
	Remove-Variable to
	Remove-Variable name
	Remove-Variable email
}
$pageRecips = @()
Foreach ($item in $pageTo) {
	$to = New-Object psobject
	$name = ($item.split(";"))[0]
	$email = ($item.split(";"))[1]
	Add-Member -InputObject $to -MemberType NoteProperty -Name Name -Value $name
	Add-Member -InputObject $to -MemberType NoteProperty -Name Email -Value $email
	$pageRecips += $to
	Remove-Variable to
	Remove-Variable name
	Remove-Variable email
}
if ($diag -eq $true) {
	[string] $("mailRecipients:") | Out-File $diagLogFile -Append 
	$mailRecips | Out-File $diagLogFile -Append
	[string] $("pageRecipients:") | Out-File $diagLogFile -Append 
	$pageRecips | Out-File $diagLogFile -Append
}
## Parse "-AlertID" input parameter: ##
$alertID = $alertID.toString()
#remove "{" and "}" around the $alertID if exist
if ($alertID.substring(0,1) -match "{") {
	$alertID = $alertID.substring(1, ( $alertID.length -1 ))
}
if ($alertID.substring(($alertID.length -1), 1) -match "}") {
	$alertID = $alertID.substring(0, ( $alertID.length -1 ))
}
#### End Parse input parameters ####


#### Function Library: ####
function getResStateName($resStateNumber){
	[string] $resStateName = $(get-ScomAlertResolutionState -resolutionStateCode $resStateNumber).name
	$resStateName
}
function setResStateColor($resStateNumber) {
	switch($resStateNumber){
		"0" { $sevColor = "FF0000" }	#Color is Red
		"1" { $sevColor = "FF0000" }	#Color is Red
		"255" { $sevColor = "3300CC" }	#Color is Blue
		default { $sevColor = "FFF00" }	#Color is Yellow
	}
	$sevColor
}
function stripCruft($cruft) {
	#Removes "cruft" data from messages. 
	#Intended to make subject lines and alphanumeric pages easier to read
	$cruft = $cruft.replace("®","")
	$cruft = $cruft.replace("(R)","")
	$cruft = $cruft.replace("Microsoftr ","")
	$cruft = $cruft.replace("Microsoft ","")
	$cruft = $cruft.replace("Microsoft.","")
	$cruft = $cruft.replace("Windows ","")
	$cruft = $cruft.replace(" without Hyper-V","")
	$cruft = $cruft.replace("Serverr","Server")
	$cruft = $cruft.replace(" Standard","")
	$cruft = $cruft.replace(" Enterprise","")
	$cruft = $cruft.replace(" Edition","")
	$cruft = $cruft.replace(".campus","")
	$cruft = $cruft.replace(".CAMPUS","")	
	$cruft = $cruft.replace(".ad.uvm.edu","")
	$cruft = $cruft.replace(".AD.UVM.EDU","")
	$cruft = $cruft.trim()
	return $cruft
}
function fnMamlToHTML($MAMLText){
	$HTMLText = "";
	$HTMLText = $MAMLText -replace ('xmlns:maml="http://schemas.microsoft.com/maml/2004/10"');
	$HTMLText = $HTMLText -replace ("maml:para", "p");
	$HTMLText = $HTMLText -replace ("maml:");
	$HTMLText = $HTMLText -replace ("</section>");
	$HTMLText = $HTMLText -replace ("<section>");
	$HTMLText = $HTMLText -replace ("<section>");
	$HTMLText = $HTMLText -replace ("<title>", "<h3>");
	$HTMLText = $HTMLText -replace ("</title>", "</h3>");
	$HTMLText = $HTMLText -replace ("", "<li>");
	$HTMLText = $HTMLText -replace ("", "</li>");
	$HTMLText;
}
function fnTrimHTML($HTMLText){
	$TrimedText = "";
	$TrimedText = $HTMLText -replace ("&lt;", "")
	$TrimedText = $TrimedText -replace ("")
	$TrimedText = $TrimedText -replace ("")
	$TrimedText = $TrimedText -replace ("")
	$TrimedText = $TrimedText -replace ("")
	$TrimedText = $TrimedText -replace ("")
	$TrimedText = $TrimedText -replace ("")
	$TrimedText = $TrimedText -replace ("")
	$TrimedText = $TrimedText -replace ("")
	$TrimedText = $TrimedText -replace ("<h1>", "<h3>")
	$TrimedText = $TrimedText -replace ("</h1>", "</h3>")
	$TrimedText = $TrimedText -replace ("<h2>", "<h3>")
	$TrimedText = $TrimedText -replace ("</h2>", "</h3>")
	$TrimedText = $TrimedText -replace ("<H1>", "<h3>")
	$TrimedText = $TrimedText -replace ("</H1>", "</h3>")
	$TrimedText = $TrimedText -replace ("<H2>", "<h3>")
	$TrimedText = $TrimedText -replace ("</H2>", "</h3>")
	$TrimedText;
}
function buildEmail {
	## Format the message for full-HTML email
	[string] $escTxt = ""
	if ($resState -eq '1') {$escTxt = '- Repeat Count ' + $escLev.ToString()}
	[string] $script:mailSubj = "SCOM - $resStateName $escTxt - $alertSev | $moPath | $alertName"
	$mailSubj = stripCruft($mailSubj)
	[string] $script:mailErrSubj = "Error emailing SCOM Notification for Alert ID $alertID"
	[string] $webConsoleURL = $WebConsoleBaseURL+"?DisplayMode=Pivot&amp;AlertID=%7b$alertID%7d"
	[string] $psCmd = "Get-SCOMAlert -Id `"$alertID`" | format-list *"
	# Format the Mail Message Body (do not indent this block!)
	$script:MailMessage.isBodyHtml = $true
	$script:mailBody = @"



<p><b>Alert Resolution State:<Font color='$sevColor'> $resStateName </Font></b><br />
<b>Alert Severity:<Font color='$sevColor'> $alertSev</Font></b><br />
<b>Object Source (Display Name):</b> $moSource <br />
<b>Object Path:</b> $moPath <br />
</p>
<p>
<p><b>Alert Name:</b> $alertName <br />
<b>Alert Description:</b> <br />
$alertDesc <br>
"@
	if (($resState -eq 0) -or ($resState -eq 1)) {
		if ($isMonitorAlert -eq $true) {
$script:mailBody = $mailBody + @"
<b>Alert Monitor Name:</b> $MonitorName <br />
<b>Alert Monitor Description:</b> $MonitorDescription
</p>
"@
		}elseif ($isMonitorAlert -eq $false) {
			$script:mailBody = $mailBody + @"
<b>Alert Rule Name:</b> $RuleName <br />
<b>Alert Rule Description:</b> $RuleDescription <br />
"@
		}
	}
$script:mailBody = $mailBody + @"
<b>Alert Context Properties:</b><br /> 
$alertCX <br />
<b>Time Raised:</b> $timeRaised <br />
<b>Alert ID:</b> $alertID <br />
<b>Notification Status:</b> $($alert.CustomField1) </br>
<b>Notification Repeat Count:</b> $($escLev.ToString()) </p>
<p>
<b>PowerShell Alert Retrieval:</b> $psCmd <br />
<b>Web Console Link:</b> <a href=""$webConsoleURL"">$webConsoleURL</a> </p>
"@
	if (($resState -eq 0) -or ($resState -eq 1)) {
		foreach ($article in $arrArticles) {
		$articleContent = $article.content
$script:mailBody = $mailBody + @"
<p>
<b>Knowledge Article / Company Knowledge `-$($article.Language):</b>
<hr>
<p> $articleContent
<hr>
<p>

"@
		}
	}
$script:mailErrBody = @"

<p>Error occurred when excuting script located at $RMS for alert ID $alertID.
<p>
<p>Alert Resolution State: $resStateName
<p>
<p>$error
<p>
<p><b>**Use below command to view the full details of this alert in SCOM Powershell console:</b>
<p>$psCmd
<p>
<p> SCOM link:<a href=""$webConsoleURL""> $webConsoleURL </a>
 

"@ 
}
function buildPage {
	## Format the message for primitive alpha-numeric pager
	$script:moPath = stripCruft($moPath)
	[string] $escTxt = ''
	if ($resState -eq '1') {$escTxt = '- Rep Count ' +$escLev.ToString()}
	[string] $script:mailSubj = "SCOM - $resStateName $escTxt | $moPath"
	[string] $script:mailErrSubj = "Error emailing SCOM Notification for Alert ID $alertID"
	#UFT8 makes the message body look like trash.  Use ASCII (the default) instead.
	#$mailMessage.BodyEncoding =  [System.Text.Encoding]::UTF8 
	$script:MailMessage.isBodyHtml = $false
	$script:moSource = stripCruft($moSource)
	$script:alertName = stripCruft($alertName)
	$script:mailBody = "| $moSource | $alertName | $timeRaised" 
	$script:mailBody = stripCruft($mailBody)
}
function buildHeaders {
	param(
		[array]$recips
	)
	## Complete the MailMessage object:
	$script:MailMessage.Sender = $Sender
	$script:MailMessage.From = $Sender
	$script:MailMessage.Headers.Add('references',$threadID)
	# Regular (non-error) format
	if ($error.count -eq "0") { 				
		$script:MailMessage.Subject = $mailSubj
		Foreach ($item in $recips) {
			$to = New-Object System.Net.Mail.MailAddress($item.email, $item.name)
			$script:MailMessage.To.add($to)
			Remove-Variable to
		}
		$script:MailMessage.Body = $mailBody
	} 
	# Error format:
	else {									
		$script:MailMessage.Subject = $mailErrSubj
		$script:MailMessage.To.add($ErrRecipient)
		$script:MailMessage.Body = $mailErrBody
	}
	## Log the message if in diag mode:
	if ($diag -eq $true) {
		[string] $('Mail Message Object Content:') | Out-File $diagLogFile -Append
		$mailMessage | fl * | Out-File $diagLogFile -Append
	}
}
#### End Function Library ####


#### Clean up existing logs: ####
if (Test-Path $errorLogFile) {Remove-Item $errorLogFile -Force}
if (Test-Path $diagLogFile) {Remove-Item $diagLogFile -Force}
if ($diag -eq $true) {
	[string] $("AlertID : `t" + $alertID) | Out-File $diagLogFile -Append
	[string] $("MailTo      : `t" + $mailto) | Out-File $diagLogFile -Append
	[string] $("PageTo      : `t" + $pageto) | Out-File $diagLogFile -Append
	#[string] $("Format  : `t" + $format) | Out-File $diagLogFile -Append
}



#### Begin Alert Handling: ####
## Locate the specific alert:
$alert = Get-SCOMAlert -Id $alertID
if ($diag -eq $true) {
	[string] $('SCOM Alert Object Content:') | Out-File $diagLogFile -Append
	$alert | fl | Out-File $diagLogFile -Append
}
## Read Alert Informaiton:
[string] $alertName = $alert.Name
[string] $alertDesc = $alert.Description
#[string] $alertPN = $alert.principalName
[string] $moSource = $alert.monitoringObjectDisplayName 	# Display name is "Path" in OpsMgr Console.
[string] $moId = $alert.monitoringObjectID.tostring()
#[string] $moName = $alert.MonitoringObjectName 			# Formerly "strAgentName"
[string] $moPath = $alert.MonitoringObjectPath 				# Formerly "pathName
#[string] $moFullName = $alert.MonitoringObjectFullName 	# Formerly "alertFullName"
[string] $ruleID = $alert.MonitoringRuleId.Tostring()
[string] $resState = ($alert.resolutionstate).ToString()
[string] $resStateName = getResStateName $resState
[string] $alertSev = $alert.Severity.ToString() 			# Formerly "severity"
if ($alertSev.ToLower() -match "error") {
	$alertSev = "Critical" 									# Rename Severity to "Critical"
}
[string] $sevColor = setResStateColor $resState				# Assign color to alert severity
#$problemID = $alert.ProblemId
$alertCx = $(1($alert.Context)).DataItem.Property `
	| Select-Object -Property Name,'#text' `
	| ConvertTo-Html -Fragment								# Alert Context property data, in HTML
$localTimeRaised = ($alert.timeraised).tolocaltime()
[string] $timeRaised = get-date $localTimeRaised -Format "MMM d, h:mm tt"
[bool] $isMonitorAlert = $alert.IsMonitorAlert
$escLev = 1
if ($alert.CustomField2) {
	[int] $escLev = $alert.CustomField2
}
## Lookup available Knowledge articles, if new alert:
if (($resState -eq 0) -or ($resState -eq 1)) {
	$articles = $mg.Knowledge.GetKnowledgeArticles($ruleId)
	
	if (!$error) {	#no point retrieving the monitoring rule when there's error processing the alert
		#if failed to get knowledge article, remove the error from $error because not every rule and monitor will have knowledge articles.
		if ($isMonitorAlert -eq $false) {
			$rule = Get-SCOMRule -Id $ruleID		
			$ruleName = $rule.DisplayName
			$ruleDescription = $rule.Description
			if ($RuleDescription.Length -lt 1) {$RuleDescription = "None"}
		} elseif ($isMonitorAlert) {
			$monitor = Get-SCOMMonitor -Id $ruleID
			$monitorName = $monitor.DisplayName
			$monitorDescription = $monitor.Description
			if ($monitorDescription.Length -lt 1) {$monitorDescription = "None"}
		}
		#Convert Knowledge articles
		$arrArticles = @()
		Foreach ($article in $articles) {
			If ($article.Visible) {
				$LanguageCode = $article.LanguageCode
				#Retrieve and format article content
				$MamlText = $null
				$HtmlText = $null
				if ($article.MamlContent -ne $null) {
					$MamlText = $article.MamlContent
					$articleContent = fnMamlToHtml($MamlText)
				}
					
				if ($article.HtmlContent -ne $null) {
					$HtmlText = $article.HtmlContent
					$articleContent = fnTrimHTML($HtmlText)
				}
				$objArticle = New-Object psobject
				Add-Member -InputObject $objArticle -MemberType NoteProperty -Name Content -Value $articleContent
				Add-Member -InputObject $objArticle -MemberType NoteProperty -Name Language -Value $LanguageCode
				$arrArticles += $objArticle
				Remove-Variable LanguageCode, articleContent
			}
		}	
	}
	if ($Articles -eq $null) {
		$articleContent = "No resolutions were found for this alert."
	}
}
## End Knowledge Article Lookup
#### End Alert Handling ####



#### Begin Mail Processes:
if ($mailto) {
	# For all alerts, send full HTML email:
	$MailMessage = New-Object System.Net.Mail.MailMessage
	buildEmail
	buildHeaders -recips $mailRecips
	invoke-command -ScriptBlock {$SMTPClient.Send($MailMessage)} -errorVariable smtpRet
}
if ($pageTo) {
	# For page-worthy alerts, format short message and send:
	$MailMessage = New-Object System.Net.Mail.MailMessage
	buildPage
	buildHeaders -recips $pageRecips
	invoke-command -ScriptBlock {$SMTPClient.Send($MailMessage)} -errorVariable smtpRet
}
#### End Mail Message Formatting #### 


# Populate CustomField1 and 2 to indicate that a notification has been sent, with repeat count.
if (!$smtpRet) { 							# IF the message was sent (apparently)...
	[string] $updateReason = "Updated by Email notification script."
	[string] $custVal1 = "notified"
	if ($resState -eq "0") { 				# . AND IF this is a "new" alert...
		$alert.ResolutionState = 1			# ..Set the resolution state to "Notified"
		$alert.CustomField2 = $escLev		# ..Set CustomField2 to the current notification retry count (presumably 1)
		if (!$alert.CustomField1) {			# ..AND if CustomField1 is not already defined...
			$alert.CustomField1 = $custVal1	# ... Set CustomField1.
		}
		$alert.Update($updateReason)
	} 
	elseif ($resState -eq "1") {		# .Or,If this is a "notified" alert
		if ($alert.CustomField2) {		# ..and the notification retry count exists..
			$escLev += 1				# ...Increment by one.
		}
		$alert.CustomField2 = $escLev
		$alert.Update($updateReason)
	}
}



Write-Host $error
##Make sure the script is closed
if ($error.count -ne "0") {
	[string]$('AlertID string: ' + $alertID) | Out-File $errorLogFile
	[string]$('Alert Object Content: ') | Out-File $errorLogFile
	$alert | Format-List * | Out-File $errorLogFile
	[string]$('Error Object contents:') | Out-File $errorLogFile
	$Error | Out-File $errorLogFile
}
#Remove-Variable alert
#Remove-Module OperationsManager

