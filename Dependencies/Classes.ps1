class myMath {
    [decimal] Pow ($a, $b) {
        return [math]::pow($a, $b)
    }

    [decimal] Sqrt ($a) {
        return [math]::sqrt($a)
    }

    [decimal] Round ($a, $b = 2) {
        return [math]::round($a, $b)
    }

    [int64] Ceil ($a) {
        return [math]::ceiling($a)
    }

    [int64] Floor ($a) {
        return [math]::floor($a)
    }

    [decimal] Log ($a, $b = 10) {
        return [math]::log($a, $b)
    }

    [decimal] Log10 ($a) {
        return [math]::log($a, 10)
    }

    [decimal] Min ($a, $b) {
        return [math]::min($a, $b)
    }

    [decimal] Max ($a, $b) {
        return [math]::max($a, $b)
    }

    [decimal] Clamp ($val, $min, $max) {
        $val = [math]::max($val, $min)
        $val = [math]::min($val, $max)
        return $val 
    }

    [bool] Positive ($a) {
        return ($a -gt 0)
    }

    [bool] Negative ($a) {
        return ($a -lt 0)
    }

    [bool] Zero ($a) {
        return ($a -eq 0)
    }

    [bool] NearZero ($a) {
        return ([int16]$a -eq 0)
    }

    [bool] Odd ($a) {
        return ([bool]($a % 2))
    }

    [bool] Even ($a) {
        return (![bool]($a % 2))
    }

    [bool] Between ($val, $min, $max) {
        return ($val -ge $min -or $val -le $max)
    }

    [string] Parity ($a) {
        return ("Even", "Odd")[$a % 2]
    }

    #math base conversions
    [uint32] ConvertFromHex ([string]$hex) {
        $hex = $hex.split("x")[-1]
        return [uint32]"0x$hex"
    }
}

class systemRoot {
    [System.IO.DirectoryInfo] $root
    [System.IO.DirectoryInfo] $user
    [hashtable] $appdata = @{
        Local    = $null
        LocalLow = $null
        Roaming  = $null
    }
    [System.IO.DirectoryInfo] $documents
    [hashtable] $programs = @{
        x86  = $null
        x64  = $null
        user = $null
    }
    [System.IO.DirectoryInfo] $system32

    systemRoot() {
        $This.Init((Get-Item "$((Get-WmiObject Win32_OperatingSystem).SystemDrive)\"), [Environment]::Get_UserName())
    }
    
    hidden Init([System.IO.DirectoryInfo]$SystemRoot, [string]$User) {
        $rootStr = $SystemRoot.FullName
        $userStr = (Get-Item "$rootStr\users\$User").FullName
        $This.Root = $SystemRoot
        $This.User = Get-Item $userStr
        $This.Appdata.Local = Get-Item "$userStr\appdata\local"
        $This.Appdata.LocalLow = Get-Item "$userStr\appdata\locallow"
        $This.Appdata.Roaming = Get-Item "$userStr\appdata\roaming"
        $This.Documents = Get-Item "$userStr\documents\"
        $This.Programs.x86 = Get-Item "$rootStr\Program Files (x86)"
        $This.Programs.x64 = Get-Item "$rootStr\Program Files"
        $This.Programs.user = Get-Item "$rootStr\programs"
        $This.System32 = Get-Item "$rootStr\Windows\System32"
    }
}

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

class ParadoxGame {
    [String]$Game
    [String]$Modding
    [String]$Workshop
    [String]$Meta
    [UInt32]$SteamID

    ParadoxGame(){
        $This.Init($null,$null,$null,$null,$null)
    }

    ParadoxGame([String]$Game){
        $This.Init($Game)
    }

    hidden Init([String]$Game,[String]$Modding,[String]$Workshop,[String]$Meta,[UInt32]$SteamID){
        $This.Game = $Game
        $This.Modding = $Modding
        $This.$Workshop = $Workshop
        $This.Meta = $Meta
        $This.SteamID = $SteamID
    }
}

class HostInfo {
    [System.Diagnostics.Process]$HostProcess
    [System.Diagnostics.Process]$ParentProcess
    [System.IO.FileInfo]$HostApplication
    [System.IO.FileInfo]$ParentApplication

    HostInfo(){$This.Init($null,$null,$null,$null)}
    HostInfo([int]$hPID){
        $This.Init((Get-Process -id $hPID),$null,$null,$null)
    }
    HostInfo([System.Diagnostics.Process]$Process){
        $This.Init($Process,(Get-Item $Process.Path),$null,$null)
    }

    hidden Init([System.Diagnostics.Process]$hProc,[System.IO.FileInfo]$hApp,[System.Diagnostics.Process]$pProc,[System.IO.FileInfo]$pApp){
        if($null -eq $hProc){Write-Error "Constructor requires either a `$PID or Process Object to function."}
        if($null -eq $hApp){$hApp = (Get-Item $hProc.Path)}
        if($null -eq $pProc){if($hProc.Parent){$pProc = $hProc.Parent}else{$pProc = [System.Diagnostics.Process]$null}}
        if($null -eq $pApp){if([System.Diagnostics.Process]$null -eq $pProc){$pApp = [System.IO.FileInfo]$null}else{$pApp = (Get-Item $pProc.Path)}}

        $This.HostProcess = $hProc
        $This.HostApplication = $hApp
        $This.ParentProcess = $pProc
        $This.ParentApplication = $pApp
    }
}

#class helpObject {}

#class FlagStatus {}

class FlagInfo {
    [String]$Name
    [String]$Default
    [String[]]$Aliases
    [String]$Description
    [String[]]$Examples

    #Constructors
    FlagInfo() { $This.init($null, $null, $null, $null, $null) }
    FlagInfo([String]$Name) { $This.init($Name, $null, $null, $null, $null) }
    FlagInfo([String]$Name, [String]$Default) { $This.init($Name, $Default, $null, $null, $null) }
    FlagInfo([String]$Name, [String]$Default, [String[]]$Aliases) { $This.init($Name, $Default, $Aliases, $null, $null) }
    FlagInfo([String]$Name, [String]$Default, [String[]]$Aliases, [String]$Description) { $This.init($Name, $Default, $Aliases, $Description, $null) }
    FlagInfo([String]$Name, [String]$Default, [String[]]$Aliases, [String]$Description, [String[]]$Examples) { $This.init($Name, $Default, $Aliases, $Description, $Examples) }

    #Init
    hidden Init([String]$Name, [String]$Default, [String[]]$Aliases, [String]$Description, [String[]]$Examples) {
        $This.Name = $Name
        $This.Default = $Default
        $This.Aliases = $Aliases
        $This.Description = $Description
        $This.Examples = $Examples
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

#class SteamGame {}