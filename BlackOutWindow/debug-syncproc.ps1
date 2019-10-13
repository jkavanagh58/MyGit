# variables from start-synch
[String]$SiteServer = 'wfm-cm12-PS-01'
[String]$SiteCode = "P12"
$test = "WFM - Windows-Svr-MW - Production - 1.Monday 03:00pm-05:00pm Orchestrator"
<# Verifying query syntax
$Params = @{
    ComputerName = $siteserver
    ClassName = "SMS_Collection"
    NameSpace    = "ROOT\SMS\site_$SiteCode"
    Filter = "Name like 'Svr-MW - Production - 1.Monday 03%Orchestrator'"
}
$ccmgrp = get-ciminstance @Params
$cimsess = New-CimSession -Computer $siteserver
$mbrqry = @{
    CIMSession = $cimsess
    Namespace  = "ROOT\SMS\site_$SiteCode"
    Query      = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($ccmgrp.CollectionID)' order by name"
}
$SMSMembers = Get-CIMInstance @mbrqry
#>
# Actual Code
$cimsess = New-CimSession -Computer $siteserver
$PatchWindow = "Monday"
If ($PatchWindow){
    Write-Verbose -Message "[BEGIN]Querying for $($PatchWindow)"
    $collQuery = @{
        CIMSession = $cimsess
        NameSpace  = "ROOT\SMS\site_$SiteCode"
        ClassName  = "SMS_Collection"
        Filter     = "Name like 'svr-MW - Production%$PatchWindow%'"
    }
}
Else {
    "Gathering all CCM Groups"
    $collQuery = @{
        CIMSession = $cimsess
        NameSpace  = "ROOT\SMS\site_$SiteCode"
        ClassName  = "SMS_Collection"
        Filter     = "Name like 'svr-MW - Production -%'"
    }
}
$ccmcollections = Get-CIMInstance @collQuery  | sort-object -Property Name


<# 
    Code to verify as possible repeat issue
#>
$mbrqry = @{
    CIMSession = $cimsess
    Namespace  = "ROOT\SMS\site_$SiteCode"
    Query      = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($ccmColl.CollectionID)' order by name"
}
$SMSMembers = Get-CIMInstance @mbrqry
$SCOMGroup = get-scomgroup -DisplayName $SCOMDisplay -ErrorAction Stop
$SCOMMP = get-scommanagementpack -DisplayName $SCOMDisplay -ErrorAction Stop
# Test using Monday 03:00 Orchestrator group succesful for both so if does not apply
If ($SCOMGroup -eq $Null -or $SCOMMP -eq $Null){ }
<# 
    Next section to test
    SMSMembers will return 0, how does following logic handle
    For test case if/else clause should go to else
    Need to remove-variable on SMSMembers?
#>
if ($SMSMembers){# Verified Based on query results if will be ignored and instance sent to Else statement}
Else {
    "`tNo instances to process"
    $logactivitySplat = @{
        logMessage = "Check $($SCOMGroup) - Message: No instances to process"
        entryType  = "Information"
        logFile    = $LogFile
    }
    log-activity @logactivitySplat
}
If ($SMSMebers){"Work to do"}
Else {"No items in CfgMgr Collection Moving on"}
<# Debug Thoughts
    Test of above loop worked as expected but not in current sync
    Current source does not include an else statement; remove-variable instances could
    be easy stop gap but not comprehensive solution
#>