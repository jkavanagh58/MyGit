# Example of using .Net to compress files
Param(
    	[Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = "Directory of files to be Compressed.")]
        [Alias("SourceFolder")]
        [ValidateScript({ test-path $_ })]
        [System.String]$srcFolder,
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = "Location of compressed file.")]
        [Alias("ZipFile")]
        [ValidateScript({ test-path -Path (Split-Path -Path $_ ) })]
        [System.String]$resultFile
)
BEGIN {
    [Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" ) | out-null
    $CompressionLevel    = [System.IO.Compression.CompressionLevel]::Optimal
}
PROCESS {
    [System.IO.Compression.ZipFile]::CreateFromDirectory($srcFolder, $resultFile, $CompressionLevel, $null)
}
END {
    Remove-Variable -Name srcFolder, resultfile
    [System.GC]::Collect()
}
