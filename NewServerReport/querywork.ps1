# 09.06.2017 JJK:	Tested .. does not work with PS Core 6 to do AD Module
If ((get-date).Month -eq 1){
	# Handle report run in January
	$newServers = get-adcomputer -Filter {OperatingSystem -like "*Server*"} -Properties OperatingSystem, WhenCreated |
	where {(get-date($_.WhenCreated)).Month -eq 12 -And (get-date($_.WhenCreated)).Year -eq (get-date).AddYears(-1).Year}
}
Else {
	$newServers = get-adcomputer -Filter {OperatingSystem -like "*Server*"} -Properties OperatingSystem, WhenCreated |
	where {(get-date($_.WhenCreated)).Month -eq (get-date).AddMonths(-1).Month -And (get-date($_.WhenCreated)).Year -eq (get-date).Year}
}
$newservers | select-object Name, WhenCreated | Sort-Object -Property WhenCreated