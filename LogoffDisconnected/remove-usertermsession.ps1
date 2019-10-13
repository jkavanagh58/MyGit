
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
Param(
		[Parameter(Mandatory = $true,
			ValueFromPipeline = $true,
			Position = 1,
			HelpMessage = "Enter Help Message Here")]
			[ValidateScript({ get-aduser $_ })]
		[System.String]$username,
		[Switch]$disconnect
)
Begin{
	$Report = @()
	$terminal_servers = @(
		"wfm-tools-ts-01",
		"wfm-tools-ts-02",
		"wfm-rae-ts-01",
		"wfm-rae-ts-02",
		"tst-tools-ts-01"
	)
    $ErrorActionPreference = "SilentlyContinue"
}
Process {
	ForEach ($ts in $terminal_servers) {
		"Checking for sessions on {0}." -f $ts
        $sess = (qwinsta $username /server:$ts)
		# Process disconnected sessions if they exist
		if ($sess){
			$sess | select -Skip 1 | ForEach {
			"Found a session on {0}" -f $ts
				 $sessobj = [pscustomobject]@{
					ServerName = $ts
					SessionID = ($_ -split (' +'))[2]
					SessionStatus = ($_ -split (' +'))[3]
				}
				$Report += $sessobj
			}
			if ($disconnect){
				#logoff
			}
		}
	}
	$Report
}