#"11212018-1.Monday 01 30am-03 00"
$SCOMDisplay = "WFM - Windows-Svr-MW - Production - 1.Monday 12:00am-02:00am"
$numRegex =  '^\d.'
$grpShortName = $SCOMDisplay.Replace("WFM - Windows-Svr-MW - Production - ","").Replace(":","").Replace(" ","") -Replace ($numRegex,"")

# Data Table Names needed additional pruning... hyphen/dash symbol is an illegal character
$tblName = "tbl{0}{1}" -f (Get-Date -f MMddyyyy), $grpShortName
# Need to remove hyphen seperating start and end times
$tblName = $tblName.Replace("-","")