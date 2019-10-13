# Test Round One
$ccmCollection = "Svr-MW - Production - 2.Tuesday 0200pm-0400pm"
If ($ccmcollection -match "0200pm"){$ccmcollection = $ccmcollection.Replace("0200pm","02:00pm")}
If ($ccmcollection -match "0300pm"){$ccmcollection = $ccmcollection.Replace("0300pm","03:00pm")}
If ($ccmcollection -match "0400pm"){$ccmcollection = $ccmcollection.Replace("0400pm","04:00pm")}
If ($ccmcollection -match "0500pm"){$ccmcollection = $ccmcollection.Replace("0500pm","05:00pm")}
$SCOMDisplay = "WFM - Windows-" + $ccmcollection
$SCOMDisplay