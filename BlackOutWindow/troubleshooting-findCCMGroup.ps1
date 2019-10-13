# Used to check to find members of CCM Patching group
[String]$SiteServer = 'wfm-cm12-PS-01'
$grp = "WFM - Windows-Svr-MW - Production - 3.Wednesday 10:00pm-12:00am Orchestrator"
$ccmgrpName = "Svr-MW - Production - 3.Wednesday 10:00pm-12:00am Orchestrator"
    $collQuery = @{
    Computername = $siteServer
    NameSpace    = "ROOT\SMS\site_P12"
    Class        = "SMS_Collection"
    Filter       = "Name='$ccmgrpName'"
}
$ccmColl = gwmi @collQuery
$mbrqry = @{
    ComputerName = $SiteServer
    Namespace    = "ROOT\SMS\site_P12"
    Query        = "SELECT * FROM SMS_FullCollectionMembership WHERE CollectionID='$($ccmColl.CollectionID)' order by name"
}
$SMSMembers = Get-WmiObject @mbrqry
$SMSMembers | Sort-Object -Property | Select-Object -Property Name