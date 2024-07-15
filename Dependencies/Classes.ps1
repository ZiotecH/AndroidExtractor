class timeTable {
    [uint32]$Year
    [uint16]$Month
    [uint16]$Day
    [uint16]$Hour
    [uint16]$Minute
    [uint16]$Second

    timeTable() {
        $this.Year = 0
        $this.Month = 1
        $this.Day = 1
        $this.Hour = 0
        $this.Minute = 0
        $this.Second = 0
    }

    timeTable([uint32]$Year) {
        $this.Init($Year, 0, 0, 0, 0, 0)
    }

    timeTable([uint32]$Year, [UInt16]$Month) {
        $this.Init($Year, $Month, 0, 0, 0, 0)
    }

    timeTable([uint32]$Year, [UInt16]$Month, [UInt16]$Day) {
        $this.Init($Year, $Month, $Day, 0, 0, 0)
    }

    timeTable([uint32]$Year, [UInt16]$Month, [UInt16]$Day, [UInt16]$Hour) {
        $this.Init($Year, $Month, $Day, $Hour, 0, 0)
    }

    timeTable([uint32]$Year, [UInt16]$Month, [UInt16]$Day, [UInt16]$Hour, [UInt16]$Minute) {
        $this.Init($Year, $Month, $Day, $Hour, $Minute, 0)
    }

    timeTable([uint32]$Year, [UInt16]$Month, [UInt16]$Day, [UInt16]$Hour, [UInt16]$Minute, [UInt16]$Second) {
        $this.Init($Year, $Month, $Day, $Hour, $Minute, $Second)
    }

    timeTable([datetime]$inputObject) {
        $this.Year = $inputObject.Year
        $this.Month = $inputObject.Month
        $this.Day = $inputObject.Day
        $this.Hour = $inputObject.Hour
        $this.Minute = $inputObject.Minute
        $this.Second = $inputObject.Minute
    }

    hidden $DaysTable = @{
        1  = 31
        2  = 28
        3  = 31
        4  = 30
        5  = 31
        6  = 30
        7  = 31
        8  = 31
        9  = 30
        10 = 31
        11 = 30
        12 = 31
    }

    hidden [bool] IsLeap ([uint32]$Year) {
        if ($Year % 4 -eq 0) {
            if ($Year % 100 -ne 0) {
                $this.FixLeap($true)
            }
            elseif ($Year % 400 -eq 0) {
                $this.FixLeap($true)
            }
            else {
                $this.FixLeap($false)
            }
            return $true
        }
        return $false
    }

    hidden[void] FixLeap ([bool]$isLeap) {
        if ($isLeap) {
            $this.DaysTable[2] = 29
        }
        else {
            $this.DaysTable[2] = 28
        }
    }


    hidden Init([uint32]$Year, [uint16]$Month, [uint16]$Day, [uint16]$Hour, [uint16]$Minute, [uint16]$Second) {
        $this.IsLeap($Year)
        $clampedMonth = [myMath]::clamp($Month, 1, 12)
        $clampedDay = [myMath]::Clamp($Day, 1, $This.DaysTable[$clampedMonth])
        $This.Year = $Year
        $This.Month = $clampedMonth
        $This.Day = $clampedDay
        $This.Hour = [myMath]::Clamp($Hour, 0, 23)
        $This.Minute = [myMath]::Clamp($Minute, 0, 59)
        $This.Second = [myMath]::Clamp($Second, 0, 59)
    }
}

class timeObject {
    [timeTable]$timeTable
    [hashtable]$stringTable = @{
        dateTime = $null
        date     = $null
        time     = $null
    }

    timeObject() {
        $this.Init(
            [timeTable]::new(),
            @{dateTime = $null
                date   = $null
                time   = $null
            }
        )
    }
    timeObject([timetable]$timeTable) {
        $This.Init(
            $timeTable,
            @{
                dateTime = $null
                date     = $null
                time     = $null
            }
        )
    }

    timeObject([timetable]$timeTable, [hashtable]$stringTable) {
        $This.Init($timeTable, $stringTable)       
    }

    hidden Init([timeTable]$timeTable, [hashtable]$stringTable) {
        $This.timeTable = $timeTable
        switch ($stringTable.Keys) {
            'dateTime' { $This.stringTable.dateTime = $stringTable.dateTime }
            'date' { $This.stringTable.date = $stringTable.date }
            'time' { $This.stringTable.time = $stringTable.time }
        }
    }
}

class DownloadInfo {
    [Bool]$Success
    [String]$Source
    [String[]]$Flags
    [String]$Name
    [String]$Extension
    [String]$Destination
    [Exception]$Exception
    [String]$Message
    [System.IO.FileInfo]$Result
    [UInt64]$Seconds

    DownloadInfo(){$This.Init($false,$null,$null,$null,$null,$null,$null,$null,$null,$null)}
    DownloadInfo([Bool]$Success){$This.Init($Success,$null,$null,$null,$null,$null,$null,$null,$null,$null)}
    DownloadInfo([Bool]$Success,[String]$Source){$This.Init($Success,$Source,$null,$null,$null,$null,$null,$null,$null,$null)}
    DownloadInfo([Bool]$Success,[String]$Source,[System.IO.FileInfo]$Result,[UInt64]$Seconds){$This.Init($Success,$Source,$null,$null,$null,$null,$null,$null,$Result,$Seconds)}
    DownloadInfo([Bool]$Success,[String]$Source,[Exception]$Exception){$This.Init($Success,$Source,$null,$null,$null,$null,$Exception,$Null,$null,$null)}
    DownloadInfo([Bool]$Success,[String]$Source,[string[]]$Flags,[String]$Name,[String]$Extension,[String]$Destination,[Exception]$Exception,[String]$Message,[System.IO.FileInfo]$Result,[UInt64]$Seconds){
        $This.Init($Success,$Source,$Flags,$Name,$Extension,$Destination,$Exception,$Message,$Result,$Seconds)
    }

    hidden Init([Bool]$Success,[String]$Source,[String[]]$Flags,[String]$Name,[String]$Extension,[String]$Destination,[Exception]$Exception,[String]$Message,[System.IO.FileInfo]$Result,[UInt64]$Seconds){
        $This.Success = $Success
        $This.Source = $Source
        $This.Flags = $Flags
        $This.Name = $Name
        $This.Extension = $Extension
        $This.Destination = $Destination
        $This.Exception = $Exception
        $This.Message = $Message
        $This.Result = $Result
        $This.Seconds = $Seconds
    }
}