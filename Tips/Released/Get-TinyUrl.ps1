function Get-TinyURL {
	<#
		.DESCRIPTION
			This function helps a user to create ashortened URL using tinyurl. Simply provide a Uri and the function will request
			a shortened version sponsored by tinyurl
		.LINK http://www.powershell.amsterdam/2015/03/24/url-shortening-with-powershell/
			Reference for this code
		.PARAMETER URI
			Text string of the full URL to be shortened.
		.EXAMPLE
			get-tinyurl -Uri "https://www.wegmans.com" -WriteClipboard
			This example will provide a shortened URL for www.wegmans.com and the shortened URL is written to your clipboard.
		.EXAMPLE
			get-tinyurl -WriteClipboard
			This example takes the Url from the clipboard, shortens it and then writes the shortened verions to the clipboard.
	#>
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True,ParameterSetName = 'URI')] [string] $Uri,
		[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True,ParameterSetName = 'ReadClipboard')] [switch] $ReadClipboard,
		[Parameter(Mandatory = $False, ValueFromPipelineByPropertyName = $True)] [switch] $WriteClipboard = $False
	)
	Process
	{
		If ($ReadClipboard -or $WriteClipboard) {
			$null = Add-Type -AssemblyName System.Windows.Forms
		}
		If ($ReadClipboard) {
			$Uri = [system.windows.forms.clipboard]::GetData('System.String')
		}
		$tinyURL = Invoke-WebRequest -Uri "http://tinyurl.com/api-create.php?url=$Uri" |
			Select-Object -ExpandProperty Content
		If ($WriteClipboard) {
			[system.windows.forms.clipboard]::SetData('System.String',$tinyURL)
		}
		$hash = @{
			Uri     = $Uri
			TinyURL = $tinyURL
		}
		New-Object -TypeName PsObject -Property $hash
	}
}