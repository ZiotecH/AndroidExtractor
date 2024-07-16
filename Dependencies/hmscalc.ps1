#hms calc

function global:HourMinuteSecond-Calculator {
    param(
        [int64][parameter(Mandatory=$true,ValueFromPipeline=$true)]$query,
        [int32][parameter(Mandatory=$false)]$returnMethod
    )

    process{

        if($PSBoundParameters.ContainsKey('returnMethod') -eq $false){
            $returnMethod = -1;
        }
        $payload = $query;
        $hmsTable = 0,0,0,0,0;
        $divTable = ((3600*24)*365),(3600*24),3600,60,1;
        if($payload -ge $divTable[0]){
            $tempVal = [math]::floor($payload/$divTable[0])
            $hmsTable[0] += $tempVal;
            $payload -= ($tempVal*$divTable[0]);
        }
        if($payload -ge $divTable[1]){
            $tempVal = [math]::floor($payload/$divTable[1])
            $hmsTable[1] += $tempVal;
            $payload -= ($tempVal*$divTable[1]);
        }
        if($payload -ge $divTable[2]){
            $tempVal = [math]::floor($payload/$divTable[2])
            $hmsTable[2] += $tempVal;
            $payload -= ($tempVal*$divTable[2]);
        }
        if($payload -ge $divTable[3]){
            $tempVal = [math]::floor($payload/$divTable[3])
            $hmsTable[3] += $tempVal;
            $payload -= ($tempVal*$divTable[3]);
        }
        $hmsTable[4] = $payload
        [string]$hmsString = "";
        if($hmsTable[0] -gt 0){
            $hmsString += ($hmsTable[0].ToString("00") + "y ");
         }
         if($hmsTable[1] -gt 0 -or $hmsTable[0] -gt 0){
            $hmsString += ($hmsTable[1].ToString("00") + "d ");
         }
        if($hmsTable[2] -gt 0 -or $hmsTable[1] -gt 0 -or $hmsTable[0] -gt 0){
           $hmsString += ($hmsTable[2].ToString("00") + "h ");
        }
        if($hmsTable[3] -gt 0 -or $hmsTable[2] -gt 0 -or $hmsTable[1] -gt 0 -or $hmsTable[0] -gt 0){
            $hmsString += ($hmsTable[3].toString("00") + "m ");
        }
        $hmsString += ($hmsTable[4].ToString("00") + "s");
        $hmsETA = Get-Date ((Get-Date) + (New-TimeSpan -Seconds $query));
        $hmsObject = [PSCustomObject]@{
            string = $hmsString;
            seconds = $hmsTable[4];
            minutes = $hmsTable[3];
            hours = $hmsTable[2];
            days = $hmsTable[1];
            years = $hmsTable[0];
            eta = $hmsETA;
        }
        switch($returnMethod){
            0{return $hmsString}
            1{return $hmsTable}
            2{return $hmsObject}
            3{return $hmsETA}
            Default{return $hmsString,$hmsTable,$hmsObject,$hmsETA}
        }
        [GC]::Collect();
    }
}

Set-Alias "hmsCalc" "HourMinuteSecond-Calculator" -Description "user";