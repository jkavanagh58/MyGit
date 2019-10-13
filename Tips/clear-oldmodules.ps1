$mods = get-installedmodule
foreach ($Mod in $mods) {
    $specificmods = get-installedmodule $mod.name -allversions
    foreach ($sm in $specificmods) {
        if ($sm.version -ne $latest.version) {
            Write-Information -MessageData "Removing version $($sm.version) of $($sm.name)" -InformationAction Continue
            $sm | uninstall-module -force
        }
    }
}