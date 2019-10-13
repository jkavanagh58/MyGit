Function get-sidder {
    <#
        simple example of how to use PowerShell in place
        of GUI application
    #>
    $uuVHDs = get-childitem *vhdx -Path c:\temp
    ForEach ($uuVHD in $uuVHDs){
        $sidVal = $uuVHD.BaseName -Replace "UVHD-"
        get-aduser $sidVal | select-object -property Name
    }
}