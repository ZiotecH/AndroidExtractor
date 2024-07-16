function global:Get-Time {
    param(
        [switch][Alias("dt")][parameter(Mandatory = $false)]$dateTime,
        [switch][Alias("t")][parameter(Mandatory = $false)]$Table,
        [switch][Alias("f","fn","fnf")][parameter(Mandatory = $false)]$fileNameFriendly,
        [switch][Alias("do")][parameter(Mandatory = $false)]$dateOnly,
        [switch][Alias("r","rev")][Parameter(Mandatory = $false)]$Reverse,
        [int16][Alias("df")][Parameter(Mandatory = $false)]$dateFormat = 0,
        [int16][Alias("tf")][Parameter(Mandatory = $false)]$timeFormat = 0,
        [int16][Alias("sf")][Parameter(Mandatory = $false)]$stringFormat = 0,
        [int16][Alias("wf")][Parameter(Mandatory = $false)]$whiteSpaceFormat = 0,
        [int16][Alias("rm")][Parameter(Mandatory = $false)]$returnMethod = 0
    )

    begin{
        #Clamp $dateFormat and $timeFormat
        [int16]$dateFormat = $Math.Clamp($dateFormat, 0, 3)
        [int16]$timeFormat = $Math.Clamp($timeFormat, 0, 3)
        [int16]$stringFormat = $math.Clamp($stringFormat, 0, 1)
        [int16]$whiteSpaceFormat = $math.Clamp($whiteSpaceFormat, 0, 1)
        [int16]$returnMethod = $math.Clamp($returnMethod, 0, 6) # How many permutations?

        #Handle -Reverse flag
        if($Reverse){
            if($Math.Between($dateFormat, 0, 1)){   [int16]$dateFormat     +=  2   }
            if($Math.Between($timeFormat, 0, 1)){   [int16]$timeFormat     +=  2   }
            if($stringFormat -eq 0){                [int16]$stringFormat   =   1   }
        }

        if($dateOnly){  $returnMethod = 1   }
        if($dateTime){  $returnMethod = 2   }
        if($table){     $returnMethod = 3   }

    }

    process {
        $date = Get-Date
        $timeTable = [timeTable]::New($date)
        $timeArray = $null

        $formatTable = @{
            date       = @{
                [int16]0 = "dd-MM-yyyy" # Universal
                [int16]1 = "MM-dd-yyyy" # American Format
                [int16]2 = "yyyy-MM-dd" # Reverse Universal
                [int16]3 = "yyyy-dd-MM" # Reverse American?
            }
            time       = @{
                [int16]0 = "HH:mm:ss"   # Universal
                [int16]1 = "HH:mm"      # Hour/Minute Only
                [int16]2 = "ss:mm:HH"   # Reversed Universal?
                [int16]3 = "mm:HH"      # Reverse Hour/minute?
            }
            whiteSpace = @{
                [int16]0 = "_"
                [int16]1 = "-"
            }
            arrayType  = @{
                0 = ($timeTable.Hour, $timeTable.Minute, $timeTable.Second)
                1 = ($timeTable.Year, $timeTable.Month, $timeTable.Day)
                2 = ($timeTable.Year, $timeTable.Month, $timeTable.Day, $timeTable.Hour, $timeTable.Minute, $timeTable.Second)
            }
        }
        


        $dateString = $date.ToString($formatTable.date[$dateFormat]);
        $timeString = $date.toString($formatTable.time[$timeFormat]);

        $stringTable = @{
            [int16]0 = "$dateString $timeString"
            [int16]1 = "$timeString $dateString"
        }
        
        if ($fileNameFriendly) {
            $stringTable[$stringFormat] = $stringTable[$stringFormat].Replace(" ",$formatTable["whitespace"][$whiteSpaceFormat]).Replace(":","-")
            $timeString = $timeString.Replace(":","-")
        }

        $timeObject = [timeObject]::New($timeTable,
            @{
                dateTime = $stringTable[$stringFormat]
                date = $dateString
                time = $timeString
            }
        )

        if($returnMethod -eq 3){
            if(!$dateTime -and !$dateOnly){ $timeArray = $formatTable['arrayType'][0]}
            elseif($dateOnly){              $timeArray = $formatTable['arrayType'][1]}
            elseif($dateTime){              $timeArray = $formatTable['arrayType'][2]}
        }


        switch($returnMethod){
            1 {return $dateString }
            2 {return $stringTable[$stringFormat]}
            3 {return $timeArray}
            4 {return $timeObject}
            5 {return $date}
            6 {return $null}
            default {Return $timeString}
        }

    }
}

Set-Alias 'time' 'Get-Time' -Scope Global
Set-Alias 'clock' 'Get-Time' -Scope Global
Set-Alias 'now' 'Get-Time' -Scope Global