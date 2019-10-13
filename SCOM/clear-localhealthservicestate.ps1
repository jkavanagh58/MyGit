# Quick code to flush the SCOM healthstate
stop-service healthservice
remove-item -Path "C:\Program Files\System Center Operations Manager\Agent\health service state" -confirm:$false -Recurse
start-service healthservice