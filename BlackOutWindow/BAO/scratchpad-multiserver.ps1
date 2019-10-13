$server = "oneserver twoserver threeserver"
If ($server.Contains(" ")) {
    "Handling non-delimited server list"
    $server = $server.Split(" ")
    #$RC = 1
    #Return $RC
}
ElseIf ($server.Contains(",")) {
    "Handling comma delimited server list"
    $server = $server.Split(",")
}
ForEach ($srv in $server) {
    $srv
}
$server = "oneserver,twoserver,threeserver"
# alternative method using Switch statement
Switch ($server) {
    {$PSItem.contains(" ")} {$server = $server.split(" ")}
    {$PSItem.contains(",")} {$server = $server.split(",")}
    Default	{$server}
}
ForEach ($srv in $server) {
    "Item {0}" -f $srv
}
