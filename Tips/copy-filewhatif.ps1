function copy-somefile {
[cmdletbinding(SupportsShouldProcess)]
Param (
    [parameter(Mandatory=$False, ValueFromPipeline=$True,
            HelpMessage = "File to be copied")]
    [System.String]$fileSource,
    [parameter(Mandatory=$False, ValueFromPipeline=$True,
            HelpMessage = "Destination")]
    [System.String]$fileDestination
)
    If ($PSCmdlet.ShouldProcess($fileSource," Copying ")){
        Copy-Item $fileSource -Destination $fileDestination -Verbose
    }
}
copy-somefile -filesource C:\temp\20180721_015142759_iOS.jpg -fileDestination c:\temp\delete.jpg
