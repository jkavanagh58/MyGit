Function get-statusagent.log {
Param(
    $computer
)
$varArch = (gwmi win32_operatingsystem -computer $computer).OSArchitecture
switch ($varArch)
{
    '32-Bit' {# get the last 12 lines of the statusagent.log
	            $log = gc "\\$computer\c$\Windows\System32\CCM\Logs\statusagent.log" -tail 24
	            $log
             }
    '64-Bit' {  # get the last 12 lines of the statusagent.log
    	        $log = gc "\\$computer\c$\Windows\SysWOW64\CCM\Logs\statusagent.log" -tail 24
	            $log
             }
}
clear-variable log
}
get-statusagent.log usl01376