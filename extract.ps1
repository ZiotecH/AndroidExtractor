param(
    [Alias("F","File","Src","Source","List")]$ListFile=$null,
    [Alias("D","Folder","SaveTo","Destination")]$Target=$null,
    [switch][Alias("H","Usage","U","Man","Manual","M")]$Help,
    [switch][Alias("GenerateExample","Gen","E","G")]$Example,
    [switch][Alias("Full","All","Everything","Complete","A","Automated")]$Auto,
    [string][Alias("Root", "From", "RD")]$RootDirectory = "/storage/emulated/0/"
)

#Define variables / Functions / Classes
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

$Dependencies = ("Classes.ps1","New-ArrayList.ps1", "isNull.ps1", "Write-ProgressBar.ps1", "Get-Time.ps1", "Download-File.ps1", "withFlag.ps1", "hmsCalc.ps1","DisplayInBytes.ps1");
$Applications = @{ "adb" = "https://developer.android.com/tools/releases/platform-tools#downloads"; "7zip" = "https://www.7-zip.org/download.html" }
$HalfWidth = [Math]::Floor(($Host.UI.RawUI.WindowSize.Width-1)/2);
$dlURL = "https://raw.githubusercontent.com/ZiotecH/AndroidExtractor/dev/Dependencies";
$depURLs = [PSCustomObject]@{
    cls = "$dlURL/Classes.ps1"
    adb = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
    nal = "$dlURL/New-ArrayList.ps1"
    isn = "$dlURL/isNull.ps1"
    dlf = "$dlURL/Download-File.ps1"
    wif = "$dlURL/withFlag.ps1"
    wpb = "$dlURL/Write-ProgressBar.ps1"
    get = "$dlURL/Get-Time.ps1"
    hms = "$dlURL/hmscalc.ps1"
    dib = "$dlURL/DisplayInBytes.ps1"
    zip = "https://api.github.com/repos/ip7z/7zip/releases/latest"
}
$autoVars = [PSCustomObject]@{
    depFolder = "Dependencies"
    depExist = $null

}
$DependencyStatus = @{
    "DownloadInfo" = $null
    "timeObject" = $null
    "withFlag" = $null
    "Download-File" = $null
    "New-Arraylist" = $null
    "isNull" = $null
    "Write-ProgressBar" = $null
    "DisplayInBytes" = $null
    "Get-Time" = $null
    "adb" = $null
    "hms" = $null
    "7zip" = $null
}
$autoVars.depExist = (Test-Path ".\$($autoVars.depFolder)")
if($autoVars.depExist){$autoVars.depFolder = (Get-Item ".\$($autoVars.depFolder)")}

#Check dependencies
function DependencyCheck{
    param(
        [string]$Name,
        [int]$Type
    
    )
    process {
        $local:ErrorActionPreference = 'SilentlyContinue'
        $Result = $false
        switch($Type){
            0 {
                $Result = ($null -ne (Get-Command "$Name"))
                Break
            }
            1 {
                $Result = ($null -ne (Get-Alias "$Name"))
                Break
            }
            2 {
                $Result = ($null -ne ([System.Management.Automation.PSTypeName]"$($Name)").Type)
                Break
            }
            Default {
                $Result = (Check-Existance "$Name" 0)
                Break; 
            }
        }
        return $Result
    }
}

function TestFunctionParameter{
    param(
        [string]$Name,
        [string]$Parameter
    )
    process {
        $Result = $false
        if($DependencyStatus[$Name]){
            if($null -ne (Get-Command "$Name").Parameters["$Parameter"]){$Result = $true}
        }
        
        Return $Result
    }
}
Set-Alias tfp TestFunctionParameter -Scope Local

function DependencyCheck-Wrapper {
    foreach($Dep in $Dependencies){
        $Name = $Dep.split(".")[0]
        if($Name -eq "Classes"){
            $DependencyStatus["DownloadInfo"] = DependencyCheck "DownloadInfo" 2
            $DependencyStatus["timeObject"] = DependencyCheck "DownloadInfo" 2
        }
        else{$DependencyStatus["$Name"] = DependencyCheck $Name 0}
    }
    $DependencyStatus["adb"] = DependencyCheck "adb" 1
    $DependencyStatus["7zip"] = DependencyCheck "7z" 1
}
DependencyCheck-Wrapper;

function GenerateList{
    param(
        $entries = @("DCIM","Pictures","Music","Download","Ringtones","Notifications"),
        $fileName = "example.txt"
    )
    $entries -join "`n" | Out-File "$fileName" -Encoding utf8
    Return (Write-Host "Generated `"$fileName`" at `"$((Get-Item .\).FullName)`"." -ForegroundColor DarkYellow)
}
function Write-Fail($msg) { return (Write-Host $msg -ForegroundColor Black -BackgroundColor DarkRed) }
function Write-Highlight($a,$b,$c,$x="DarkCyan",$y="Yellow"){
    Write-Host $a -ForegroundColor $x -NoNewline
    Write-Host $b -ForegroundColor $y -NoNewline
    Write-Host $c -ForegroundColor $x
}
function Write-Div($width = ($HOST.UI.RawUI.WindowSize.Width-1) ) { Return (Write-Host "$("#"*$width)" -ForegroundColor DarkGray) }
Set-Alias -Name wd -Value Write-Div -Scope Local

function ParseGitHubLink{
    param(
        [string]$URL
    )
    $local:ProgressPreference = "SilentlyContinue"
    $depURLs.zip = (((Invoke-WebRequest $depURLs.zip -UseBasicParsing).Content | ConvertFrom-Json).Assets | Where-Object{$_.Name -match "x64.msi"}).browser_download_url
}
Set-Alias "pghl" "ParseGitHubLink"

function DownloadApplication{
    param(
        [int]$Application
    )
    $File = [DownloadInfo]::New();
    $Result = [PSCUstomObject]@{
        File = $null
        Installed = $false
        Location = $null
    }
    switch($Application){
        0 {
            $depURLs.zip = pghl $depURLs.zip
            $File = (Download-File -Source $depURLs.zip -silent)
            $Result.File = $File
            if($File.Success){
                $InstallResult = (Start-Process msiexec -ArgumentList ("-a","$($File.Result)","-l","7zip-x64.log","TARGETDIR=`"$($autoVars.depFolder)\7zip`"","-passive"));
                if($InstallResult.ExitCode -ne 0){Write-Fail "Failed to install 7zip, please check '7zip-x64.log' for more details."}else{
                    $Result.Installed = $true
                    $Result.Location = (Get-Item "$($autoVars.depFolder)\7zip")
                    $DependencyStatus["7zip"] = $true
                    Remove-Item "$($Result.Location)\install.msi"
                    Copy-Item "$($Result.Location)\Files\7-zip\*" -Destination "$(Result.Location)\" -Recurse
                    Remove-Item "$(Result.Location)\Files" -Recurse -Force
                    Remove-Item $File.Result -Recurse -Force
                }
            }
            Break;
        }
        1 {
            $File = (Download-File -Source $depURLs.adb -silent)
            $Result.File = $File
            if(!$DependencyStatus["7zip"]){Return $Result}
            if($File.Success){
                7z x $File.Result;
                $Result.Installed = $true
                $Result.Location = (Get-Item ".\platform-tools")
                $DependencyStatus["adb"] = $true
            }
            Break;
        }
        Default {$File.Success = $False; Break;}
    }
    Return $Result
}

if($Help){
    write-host $null
    wd #Start
    Write-Host "`nTutorial/Help" -ForegroundColor Yellow
    [PSCustomObject]@{Description="This script will allow you to grab files or folders from your phone and compress them into archives on your pc."}|Format-List
    
    wd $HalfWidth #Div
    Write-Host "`nDependencies" -ForegroundColor Yellow
    [PSCustomObject]@{"Script Dependencies" = $Dependencies; "Application Dependencies" = $Applications}|Format-List
    
    wd $HalfWidth #Div
    Write-Host "`nScript Flags" -ForegroundColor Yellow
    [FlagInfo]::New("ListFile","`$null",("F","File","Src","Source","List"),"Defines a text file to read objects to grab from; see example.txt.",("extract.ps1 -f .\example.txt"))|Format-List
    [FlagInfo]::New("Target","`$null",("D","Folder","SaveTo","Destination"),"Defines where to save the resulting archives, if `$null it creates a folder with today's date.",("extract.ps1 -d `"myPhone`""))|Format-List
    [FlagInfo]::New("Help",$null,("H","Usage","U","Manual","Man","M"),"Prints this tutorial/help section and generates an 'example.txt'.",("extract.ps1 -h"))|Format-List
    [FlagInfo]::New("Example",$null,("GenerateExample","Gen","E","G"),"Generates an 'example.txt'.",("extract.ps1 -e"))|Format-List
    [FlagInfo]::New("RootDirectory", "/storage/emulated/0/", ("Root","From","RD"),"Defines where to pull the files from.",("extract.ps1 -from /storage/emulated/0/download/"))|Format-List
    
    wd $HalfWidth #Div
    Write-Host "`nExamples" -ForegroundColor Yellow
    [PSCustomObject]@{
        "example.ps1" = "Asks the user to input names of folders/files located in the root storage directory and then extracts them to a folder named with today's date."
        "example.ps1 -h" = "Prints this tutorial/help section and generates an 'example.txt' and then exits."
        "example.ps1 -g" = "Generates an 'example.txt' and then exits."
        "example.ps1 -d `"myPhone`"" = "Asks the user to input names of folders/files located in the root storage directory and then extracts them to a folder named `"myPhone`"."
        "example.ps1 -f `"example.txt`"" = "Grabs every name from the file `"example.txt`", extracts them from the root storage directory and puts them in a folder named with today's date."
        "example.ps1 -f `"example.txt`" -d `"myPhone`"" = "Grabs every name from the file `"example.txt`", extracts them from the root storage directory and puts them in a folder named `"myPhone`"."
    }|Format-List

    wd $HalfWidth #Div
    Write-Host "`nReturn codes" -ForegroundColor Yellow
    [PSCustomObject]@{"False"="Script has ran into an issue or was run with either -Help or -Example.";"True"="Script executed sucessfully."} | Format-List
    Write-Host $null
    wd #End

    Write-Host "`n`n"
    GenerateList
    
    return $false;
    break;
}

if($Example){
    GenerateList;
    return $false;
    break;
}


#Check environment
if(!(Get-Variable "myMods" -ErrorAction SilentlyContinue)){
    $documents = "$($HOME)\Documents"
    $t1 = ("WindowsPowerShell","Modules","PowerShell")
    $myMods = $null
    foreach($f in $t1){if((Test-Path "$($documents)\$f")){$myMods = (Get-Item "$($documents)\$f")}}
    if($autoVars.depExist){ $myMods = $autoVars.depFolder }
    if($Auto){
        #BEGIN AUTO
        $pp = $ProgressPreference
        $ea = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
        $ProgressPreference = 'SilentlyContinue'
        if(!$autoVars.depExist){ New-Item ".\$($autoVars.depFolder)" -ItemType Directory | Out-Null }
        $myMods = $autoVars.depFolder;
        Try{
            if (!$DependencyStatus["DownloadInfo"]) {
                if(!(Test-Path $myMods\Classes.ps1)){
                    Invoke-WebRequest $depURLs.cls -OutFile "$($autoVars.depFolder)\Classes.ps1" -ErrorAction Stop
                }
                . $myMods\Classes.ps1
            }
            if (!$DependencyStatus["New-ArrayList"]) {
                if(!(Test-Path $myMods\New-ArrayList.ps1)){
                    Invoke-WebRequest $depURLs.nal -OutFile "$($autoVars.depFolder)\New-ArrayList.ps1" -ErrorAction Stop
                }
                . $myMods\New-ArrayList.ps1
            }
            if(!$DependencyStatus["withFlag"] -or !(tfp "withFlag" "list")){
                if (!(Test-Path $myMods\withFlag.ps1)) {
                    Invoke-WebRequest $depURLs.wif -OutFile "$($autoVars.depFolder)\withFlag.ps1" -ErrorAction Stop
                }
                . $myMods\withFlag.ps1
            }
            if (!$DependencyStatus["DisplayInBytes"]) {
                if(!(Test-Path $myMods\DisplayInBytes.ps1)){
                    Invoke-WebRequest $depURLs.nal -OutFile "$($autoVars.depFolder)\DisplayInBytes.ps1" -ErrorAction Stop
                }
                . $myMods\DisplayInBytes.ps1
            }
            if (!$DependencyStatus["Download-File"] -or !(tfp "Download-File" "DownloadInfo")) {
                if (!(Test-Path $myMods\Download-File.ps1)) {
                    Invoke-WebRequest $depURLs.dlf -OutFile "$($autoVars.depFolder)\Download-File.ps1" -ErrorAction Stop
                }
                . $myMods\Download-File.ps1
            }
        }catch{
            Write-Fail "Failed to download dependencies.";$_;Return $false; break;
        }
        try{
            Push-Location
            Set-Location $autoVars.depFolder
            if(!$DependencyStatus["7zip"])  {$File = (DownloadApplication 0); if($File.Installed){Set-Alias "7z" (Get-Item "$($File.Location)\7z.exe")}; }
            if(!$DependencyStatus["adb"])   {$File = (DownloadApplication 1); if($File.Installed){Set-Alias "adb" (Get-Item "$($File.Location)\adb.exe")}; }
            if(!$DependencyStatus["isn"])   {$File = Download-File -source $depURLs.isn -silent; . $File.Result; }
            if(!$DependencyStatus["nal"])   {$File = Download-File -source $depURLs.nal -silent; . $File.Result; }
            if(!$DependencyStatus["wpb"])   {$File = Download-File -source $depURLs.wpb -silent; . $File.Result; }
            if(!$DependencyStatus["get"])   {$File = Download-File -source $depURLs.get -silent; . $File.Result; }
            if(!$DependencyStatus["hms"])   {$File = Download-File -source $depURLs.hms -silent; . $File.Result; }
            DependencyCheck-Wrapper
            Pop-Location
        }
        catch{
            Write-Fail "Failed to download one or more dependencies."
            Write-Host "`nException: `n" -ForegroundColor DarkYellow
            $_
            Write-Host "`nDependency that failed:`n" -ForegroundColor DarkYellow
            $File | Format-List
            Return $false; Break;
        }
        $ProgressPreference = $pp
        $ErrorActionPreference = $ea
        #End AUTO
    }
    if($null -eq $myMods){Write-Fail "Failed to find depedency folder.`nPlease make sure you have all dependencies.";Return $false;break;}
}

if($Auto){$File = (DownloadApplication 0);if($File.Installed){Set-Alias "7z" (Get-Item "$($File.Location)\7z.exe")}}
if (!$DependencyStatus["7zip"]) {
    Write-Fail "Failed to find 7z.exe, please make sure you have it installed.";
    Write-Highlight "You can download it at " $Applications["7zip"] ".";
    Return $false
    break;
}

if($Auto){$File = (DownloadApplication 1);if($File.Installed){Set-Alias "adb" (Get-Item "$($File.Location)\adb.exe")}}
if(!$DependencyStatus["adb"]) {
    Write-Fail "Failed to find adb.exe, please make sure you have it installed.";
    Write-Highlight "You can download it at " $Applications["adb"] ".";
    Return $false
    break;
}

$failedDeps = $null
foreach($dep in $Dependencies){
    if(!(Test-Path "$myMods\$dep")){$failedDeps+="$($dep)`n"}
    else{
        . $myMods\$dep
    }
}
if($null -ne $failedDeps){Write-Fail "Failed to find at least one dependency.";Write-Host "$failedDeps";Return $false;break;}

#Post-Dependency Defines
function wpb{
    param(
        [string]$msg,
        [switch]$final,
        [int32]$cur,
        [int32]$tot
    )
    return (Write-Host "`r$(Write-ProgressBar -msgPayload "$msg" -progress ($cur/$tot))$(if($final){"`n"})" -NoNewline)
}
if($null -eq $Target){$Target = (Get-Time -dateOnly -fileNameFriendly -Reverse)}

if(!$Auto){
    $grabList = New-ArrayList
}else{
    $grabList = (adb shell ls "$RootDirectory")
    GenerateList $grabList "full.txt"
}

if($null -ne $listFile){
    foreach($line in (cat $listFile)){
        $grabList.add($line)>$null
    }
}elseif(!$Auto){
    while(!$isNull){
        Write-Host "Enter the name of each folder/file to grab." -ForegroundColor Yellow
        if($grabList.Count -ge 1){
            Write-Host "`nCurrent list ($($grabList.count)):" -ForegroundColor DarkCyan
            Write-Host ("$($($grabList) -join ", ")`n") -ForegroundColor Cyan
        }
        Write-Host "Keep in mind names are " -ForegroundColor Yellow -NoNewline
        Write-Host "CASE SENSITIVE" -ForegroundColor DarkRed -NoNewline
        Write-Host "." -ForegroundColor Yellow

        if($grabList.count -ge 1){Write-Host "Enter nothing to proceed with extraction." -ForegroundColor Yellow}
        $input = Read-Host
        
        $isNull = isNull $input
        if(!$isNull){$grabList.add($input)>$null}
        Clear-Host
    }
}

if(!(Test-Path ".\$($target)")){
    New-Item "$target" -Type Directory
}

Push-Location
Set-Location ".\$($target)\"

Write-Host "Extracting $($grabList.count) objects to $($target)." -ForegroundColor Yellow
$i=0
$ExtractionStart = (Get-Date);
foreach($folder in $grabList){
    $i++
    $list = New-ArrayList
    $list.add("exec-out")>$null
    $list.add("cd $($RootDirectory) && tar -c $folder | gzip")>$null
    #$list.add(">")
    #$list.add("$($folder).tar.gz")
    #Write-Host "Extracting $folder from /storage/emulated/0/"
    wpb -msg "$folder [$($i)/$($grabList.Count)]" -cur $i -tot $grablist.Count
    adb $list > "$($folder).tar.gz"
}
$ExtractionComplete = (Get-Date);
wpb -msg "Complete" -cur $i -tot $grablist.count -final
Write-Highlight -a "Extracting " -b ($grabList.Count) -c " took $(hmsCalc (($ExtractionComplete - $ExtractionStart).TotalSeconds) 0)."
Pop-Location
Return $true
