connect-toscom
$saplist = get-content d:\etc\sapagents.txt
ForEach ($agt in $saplist){
    $fullname = "$agt.sap.swagelok.lan"
    $target = get-agent | where {$_.name -eq $fullname}
    $target | uninstall-agent
}