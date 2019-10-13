<#
.SYNOPSIS
Gets file encoding.
.DESCRIPTION
The Get-FileEncoding function determines encoding by looking at Byte Order Mark (BOM).
Based on port of C# code from http://www.west-wind.com/Weblog/posts/197245.aspx
.EXAMPLE
Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'}
This command gets ps1 files in current directory where encoding is not ASCII
.EXAMPLE
Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'} | foreach {(get-content $_.FullName) | set-content $_.FullName -Encoding ASCII}
Same as previous example but fixes encoding using set-content
# Modified by F.RICHARD August 2010
# add comment + more BOM
# http://unicode.org/faq/utf_bom.html
# http://en.wikipedia.org/wiki/Byte_order_mark
#
# Do this next line before or add function in Profile.ps1
# Import-Module .\Get-FileEncoding.ps1
#>
function Get-FileEncoding {
[CmdletBinding()]
Param (
	[Parameter(Mandatory = $True, 
		ValueFromPipelineByPropertyName = $True)]
	[string]$Path
)
BEGIN {
	[byte[]]$byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $Path
}
PROCESS {
	if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf )  {
		# EF BB BF (UTF8)
		Write-Output 'UTF8'
	}
	elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff){
		# FE FF  (UTF-16 Big-Endian)
		Write-Output 'Unicode UTF-16 Big-Endian'
	}
	elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe){
		# FF FE  (UTF-16 Little-Endian)
		Write-Output 'Unicode UTF-16 Little-Endian'
	}
	elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff){
		# 00 00 FE FF (UTF32 Big-Endian)
		Write-Output 'UTF32 Big-Endian'
	}
	elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff -and $byte[2] -eq 0 -and $byte[3] -eq 0){
		# FE FF 00 00 (UTF32 Little-Endian) 
		Write-Output 'UTF32 Little-Endian'
	}
	elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76 -and ($byte[3] -eq 0x38 -or $byte[3] -eq 0x39 -or $byte[3] -eq 0x2b -or $byte[3] -eq 0x2f) ){
		# 2B 2F 76 (38 | 38 | 2B | 2F)
		Write-Output 'UTF7'
	}
	elseif ($byte[0] -eq 0xf7 -and $byte[1] -eq 0x64 -and $byte[2] -eq 0x4c ){
		# F7 64 4C (UTF-1)
		Write-Output 'UTF-1' 
	}
	elseif ($byte[0] -eq 0xdd -and $byte[1] -eq 0x73 -and $byte[2] -eq 0x66 -and $byte[3] -eq 0x73){
		# DD 73 66 73 (UTF-EBCDIC)
		Write-Output 'UTF-EBCDIC'
	}
	elseif ( $byte[0] -eq 0x0e -and $byte[1] -eq 0xfe -and $byte[2] -eq 0xff ){
		# 0E FE FF (SCSU)
		Write-Output 'SCSU'
	}
	elseif ($byte[0] -eq 0xfb -and $byte[1] -eq 0xee -and $byte[2] -eq 0x28){
		# FB EE 28  (BOCU-1)
		Write-Output 'BOCU-1' 
	} 
	elseif ($byte[0] -eq 0x84 -and $byte[1] -eq 0x31 -and $byte[2] -eq 0x95 -and $byte[3] -eq 0x33){
		# 84 31 95 33 (GB-18030)
		Write-Output 'GB-18030'
	}
	else {
		# 84 31 95 33 (GB-18030)
		Write-Output 'ASCII'
	}
}
}
Function ContainsBOM
{
    return $input | where {
        $contents = [System.IO.File]::ReadAllBytes($_.FullName)
        $_.Length -gt 2 -and $contents[0] -eq 0xEF -and $contents[1] -eq 0xBB -and $contents[2] -eq 0xBF }
}

