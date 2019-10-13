
Describe "Script Folder" {
    It "Find Script Root" {
        (Get-Item "C:\etc\Scripts") |
        Should Be $True
    }
    It "Has enough free disk space" {
        $varRootDrive = (get-ciminstance -ClassName Win32_LogicalDiskRootDirectory | select -expand groupcomponent).DeviceID
        (get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID = '$varRootDrive'").FreeSpace |
            Should -BeGreaterThan 6524749824
    }
}
