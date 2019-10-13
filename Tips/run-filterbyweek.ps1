BEGIN {
    Function new-Calendar {
        $caldays = @()
        $startday = Get-Date "1.1.2019"
        $counter = 0
        $curDay = Get-Date
        ForEach ($day in $startday.DayOfYear..$curDay.DayOfYear) {
            $calval = (get-date $startday).AddDays($counter)
            $obj = [PSCustomObject]@{
                Date       = $calval
                DOY = $calval.DayOfYear
                WeekofYear = [int](Get-date $calval -UFormat %V)
            }
            $caldays += $obj
            $counter++
        }
        Remove-Variable counter
        Return $caldays
    }
}
PROCESS {
    $workingset = new-Calendar
    $stopPoint = [int](Get-date -UFormat %V)
    $weekCounter = 0
    Do {
        $weekCounter++
        "Checking for {0}" -f $weekcounter
        $weekdates = $workingSet | Where WeekofYear -eq $weekCounter | select Date, DOY, WeekofYear
        $1stday = ($weekdates | Measure-Object -Property Date -Minimum).Minimum
        $lastday = ($weekdates | Measure-Object -Property Date -Maximum).Maximum
        "This week started on {0} and ended {1}" -f $1stDay, $lastday
        
    } Until ($weekCounter -eq $stopPoint)
}
END {
    #Remove-Variable -Name workingset, weekcounter, weeklist, 1stDay, lastDay -ErrorAction SilentlyContinue
    [System.GC]::Collect()
}