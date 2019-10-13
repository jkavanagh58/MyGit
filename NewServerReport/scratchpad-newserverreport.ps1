$serverlist = get-adcomputer -Filter {OperatingSystem -like "*Server*"} -Properties OperatingSystem, WhenCreated |
	Select-Object -Property Name, WhenCreated, @{label="Age";expression={[Math]::Round(((get-date)-$_.WhenCreated).TotalDays)}} |
	sort-Object -Property  WhenCreated |
	Where-Object {((get-date)-(get-date($_.WhenCreated))).TotalDays -le 30}