# Code (splats are great) to add your regulatory workstation to
# your Remote Desktop Configuration Manager configuration
$newrdcmanserverSplat = @{
    GroupName   = 'Servers'
    FilePath    = '.\wegmans.rdg'
    Server      = "172.26.92.140"
    DisplayName = "Regulatory Workstation"
}
new-rdcmanserver @newrdcmanserverSplat