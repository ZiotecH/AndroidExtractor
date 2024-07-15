#stolen from the web :D
#Mostly reworked now tho >.>
function global:Download-File {

    param(
        [string][parameter(Mandatory = $false)]$source,
        [string][parameter(Mandatory = $false)]$name,
        [string][parameter(Mandatory = $false)]$extension,
        [string][parameter(Mandatory = $false)]$destination,
        [switch][parameter(Mandatory = $false)]$silent,
        [switch][parameter(Mandatory = $false)]$subroutine,
        [DownloadInfo][Parameter(Mandatory=$false)]$DownloadInfo
    )

    process {
        #Setup Variables
        $myFlags = $PSCmdlet.MyInvocation.BoundParameters.Keys
        $FlagStatus = [PSCustomObject]@{
            source = (withFlag "source" $myFlags)
            name = (withFlag "name" $myFlags)
            extension = (withFlag "extension" $myFlags)
            destination = (withFlag "destination" $myFlags)
            silent = (withFlag "silent" $myFlags)
            subroutine = (withFlag "subroutine" $myFlags)
            DownloadInfo = (withFlag "DownloadInfo" $myFlags)
        }
        [string]$OriginalName = $source.split("/")[-1]
        [bool]$noName = $false
        [bool]$noExt = $false
        [bool]$noDest = $false

        #Check keys
        if (!$FlagStatus.DownloadInfo) {$DownloadInfo = [DownloadInfo]::New()}
        if (!$FlagStatus.name) { $noName = $true }
        if (!$FlagStatus.extension) { $noExt = $true }
        if (!$FlagStatus.destination) { $noDest = $true }
        if (!$FlagStatus.source){
            if(!$FlagStatus.DownloadInfo){
                $DownloadInfo.Flags = $myFlags
                $DownloadInfo.Exception = [Exception]::New("No download source was defined.")
                $DownloadInfo.Message = "No download source was defined."
                return $DownloadInfo
            }
            else{
                $Source = $DownloadInfo.Source
                if(!(isNull $DownloadInfo.Name)){$Name = $DownloadInfo.Name;$noName = $false}
                if(!(isNull $DownloadInfo.Extension)){$Extension = $DownloadInfo.Extension;$noExt = $false}
                if(!(isNull $DownloadInfo.Destination)){$Destination = $DownloadInfo.Destination;$noDest = $false}
            }
        }
        
        
        #Sanitize
        if ($noName) {
            $name = $source.split("/")[-1]
            $splitExt = $name.split(".")[-1]
            #write-host "$name, $splitExt, " -nonewline
            $name = $name.replace(".$splitExt", "")
            #write-host "$name"
        }
        if ($noExt) { $extension = $($source.split("."))[-1] }
        if ($noDest) { $destination = (Get-Item ".\").fullname }
        if ($extension -match "\.") {
            $extension = $extension.Replace(".", "")
        }
        $combined_name = "$destination\$name.$extension"
        $winWidth = $host.ui.rawui.WindowSize.Width
        #write-host "`r$combined_name" -NoNewline
        #Stolen script
        $uri = New-Object "System.Uri" "$source"
        $startTime = Get-Date
        $request = [System.Net.HttpWebRequest]::Create($uri)
        $request.set_Timeout(15000) #15 second timeout
        try{
            $ea = $ErrorActionPreference
            $ErrorActionPreference = 'Stop'
            $response = $request.GetResponse()
            $ErrorActionPreference = $ea
        }
        catch [System.Net.WebException] {
            if($_.Exception.InnerException.Status -eq "Timeout"){
                $errMsg = "Error: Operation timed out."
                if(!$silent){
                    Write-Host "$errMsg" -ForegroundColor Red
                    Write-Host "Is '$source' available?" -ForegroundColor DarkYellow
                }
                $DownloadInfo.Success = $false
                $DownloadInfo.Flags = $myFlags
                $DownloadInfo.Exception = $_
                $DownloadInfo.Message = $errMsg
                return $DownloadInfo
            }
        }
        catch{
            $DownloadInfo.Success = $false
            $DownloadInfo.Flags = $myFlags
            $DownloadInfo.Exception = $_
            $DownloadInfo.Message = $errMsg
            Return $DownloadInfo
        }
        $rawLen = $response.get_ContentLength()
        if ($rawLen -lt 0) {
            $rawLen = 1024
        }
        $totalLength = [System.Math]::Floor($rawLen / 1024)
        if ($totalLength -lt 0) {
            if ($rawLen -gt 0) {
                $totalLength = $rawLen
            }
            else {
                $totalLength = 1
            }
        }
        if ($subroutine) {
            #$winWidth = 100
        }
        $responseStream = $response.GetResponseStream()
        try {
            #$targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $combined_name.tostring(), Create
            $targetStream = [System.IO.File]::Create($combined_name)
            try {
                $buffer = new-object byte[] 10KB
                $count = $responseStream.Read($buffer, 0, $buffer.length)
                $downloadedBytes = $count
                while ($count -gt 0) {
                    $targetStream.Write($buffer, 0, $count)
                    $count = $responseStream.Read($buffer, 0, $buffer.length)
                    $downloadedBytes = $downloadedBytes + $count
                    $currentProgress = (([System.Math]::Floor($downloadedBytes / 1024)) / $totalLength)
                    $sizeMsg = DisplayInBytes($totalLength * 1024)
                    if ($totalLength -le 1) {
                        $sizeMsg = DisplayInBytes $downloadedBytes
                    }
                    if ($currentProgress -lt 0) {
                        $currentProgress = 0.00
                    }
                    if ($currentProgress -gt 1) {
                        $currentProgress = 0
                    }
                    if ($downloadedBytes -lt 0) {
                        $downloadedBytes = 0
                    }
                    if (!$silent) {
                        
                        try {
                            Write-Host ("`r$(Write-ProgressBar -msgPayload " Downloading file '$($name).$($extension)' [$sizeMsg] - ($($currentProgress.toString("0.00%"))) " -progress $currentProgress -width $winWidth)") -nonewline
                        }
                        catch {
                            #aaaa
                            write-host "`n| DLB: $downloadedBytes `n| CP: $currentProgress `n| RL: $rawLen `n| TL: $totalLength"
                        }
                        #Write-Host "`r$(Write-ProgressBar -msgPayload $combined_name -progress $currentProgress)" -ForegroundColor $Bright -BackgroundColor Black -NoNewline
                    }
                
                }
                
                #Calculate seconds
                [UInt64]$TotalSeconds = ((Get-Date) - $startTime).totalSeconds
                #Tell user it's done
                if (!$silent -and !$subroutine) {
                    Write-Host "`r$(Write-ProgressBar -msgPayload " Finished downloading file '$($OriginalName)' " -progress 1 -width $winWidth)"
                    Write-Host "$(Write-ProgressBar -msgPayload " File located at: '$(Get-Item $combined_name)' " -progress 1 -width $winWidth)"
                    Write-Host "$(Write-ProgressBar -msgPayload " Download took $(hmsCalc $TotalSeconds 0)" -progress 1 -width $winWidth)"
                }
                $DownloadInfo.Success = $True
                $DownloadInfo.Source = $Source
                $DownloadInfo.Flags = $myFlags
                $DownloadInfo.Name = $Name
                $DownloadInfo.Extension = $Extension
                $DownloadInfo.Destination = $Destination
                $DownloadInfo.Result = (Get-Item $combined_name)
                $DownloadInfo.Message = "Successfully downloaded file '$($OriginalName)'."
                $DownloadInfo.Seconds = $TotalSeconds
            }
            catch {
                throw
            }
            #Clean up afterwards
            finally {
                if ($targetStream) {
                    $targetStream.Flush()
                    $targetStream.Close()
                    $targetStream.Dispose()
                }
            }
        }
        catch {
            $DownloadInfo.Success = $false
            $DownloadInfo.Flags = $myFlags
            $DownloadInfo.Exception = $_
            $DownloadInfo.Message = "Generic error, check attached exception."
        }
        finally {
            $responseStream.Dispose()
        }
        if(!$DownloadInfo.Success -and (Test-Path $combined_name)){rm $combined_name;}
        return $DownloadInfo

    }
}

Set-Alias 'dl' 'Download-File'