# Generic to list all entries in a Hyper-V related event log
get-eventlog -LogName System -Source *Hyper-V* -after "10/1/2017" | select-Object -Property *
# Get entries from a specific Hyper-v Log
get-eventlog -LogName System -Source *Microsoft-Windows-Hyper-V-Hypervisor* -after "10/1/2017" | select-Object -Property *


# PS Core
# Even PSCompatPack doesn't seem to help
$02sess = new-pssession -ComputerName WFM-Wintel-02 -Credential $admcreds
$logEvents = Invoke-command -Session $02sess -ScriptBlock {
    get-eventlog -LogName System -Source *Microsoft-Windows-Hyper-V-Hypervisor* -after "10/1/2017" |
    select-Object -Property *
}