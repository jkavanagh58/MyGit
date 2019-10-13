# Code being used by Chris Pressley
$terminal_servers = @(
"wfm-tools-ts-01",
"wfm-tools-ts-02",
"wfm-rae-ts-01",
"wfm-rae-ts-02",
"tst-tools-ts-01"
)
ForEach ($ts in $terminal_servers) {
	$pc = qwinsta /server:$ts | select-string "Disc" | select-string -notmatch "services"
	# Process disconnected sessions if they exist
	if ($pc){
      $pc| % { logoff ($_.tostring() -split ' +')[2] /server:$ts }
      $pc
    }
}

