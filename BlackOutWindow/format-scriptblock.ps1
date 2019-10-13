
Function format-scriptblock {
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
Param(
	$ms,
	$packID,
	$gid,
	$inst
)
$var = @"
$([char]36)args = @{
	ManagementServer = '$ms'
	ManagementPackID = '$packID'
	GroupID = '$gid'
	InstancesToAdd = $inst
}
d:\etc\scripts\modifygroupmembership.ps1 @args
"@
Return $var
}