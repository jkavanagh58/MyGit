[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
Param(
	[String]$paramFile = get-content C:\etc\testparams.txt
)
Begin{}
Process{
If (test-path $paramfile){
	[HashTable]$vmParams = @{}
	ForEach ($line in $paramFile.Where{$_ -notmatch '^#.*'}){
		$lineData = $line.Split("=")
		$vmParams.Add($lineData[0].Trim(),$lineData[1].Trim())
	}
}
# Again this is just a concept but using project oriented terms
"This script will work on migrating {0} to {1} workgroup" -f $vmParams.Param1, $vmParams.Param2
}
End{
	Remove-Variable -Name paramfile, vmParams
	[System.GC]::Collect()
}