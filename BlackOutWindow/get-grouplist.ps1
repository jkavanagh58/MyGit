$SiteServer = 'wfm-cm12-PS-01'
$ManagementServer = "WFM-OM12-MSD-02.wfm.wegmans.com"
$SiteCode = "P12"
$collQuery = @{
			Computername = $siteServer
			NameSpace    = "ROOT\SMS\site_$SiteCode"
			Class        = "SMS_Collection"
			Filter       = "Name like 'svr-MW - Production -%'"
}
$ccmcollections = get-wmiobject @collQuery  | sort Name
Start-OperationsManagerClientShell -ManagementServerName: "wfm-om12-msm-01.wfm.wegmans.com" -PersistConnection: $true -Interactive: $true
ForEach ($ccmcoll in $ccmcollections){
    $SCOMDisplay = "WFM - Windows-" + $ccmcoll.name.trim()
    Try{
        $SCOMGroup = get-scomgroup -DisplayName $SCOMDisplay -ErrorAction Stop
        "{0} matches {1}" -f $SCOMGroup.DisplayName, $ccmcoll.Name
    }
    Catch {
        "No Matches for {0} from {1}" -f $SCOMGroup.DisplayName, $ccmcoll.Name
    }
}