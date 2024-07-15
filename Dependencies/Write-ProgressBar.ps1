function Write-ProgressBar {
    param(
        [string][parameter(Mandatory = $false)]$msgPayload,
        [double][parameter(Mandatory = $false)]$progress = 0.00,
        [int32][Parameter(Mandatory = $false)]$width = 100,
        [switch][Parameter(Mandatory = $false)]$Headless,
        [switch][Parameter(Mandatory = $false)]$BasicOutput,
        [switch][Parameter(Mandatory = $false)]$CustomChars,
        [char][Parameter(Mandatory = $false)]$blockChar = $null,
        [char][Parameter(Mandatory = $false)]$shadeChar = $null
        #[string][Parameter(Mandatory=$false)]$color
    )

    process {
        if ($BasicOutput) {
            $UIStrings = [PSCustomObject]@{
                block = "="
                shade = "-"
                #template = (([char]9618).tostring()*100)
            }
        }
        elseif($CustomChars) {
            if($null -eq $blockChar){
                $blockChar = Read-Host "Enter single char for block glyph"
            }
            if($null -eq $shadeChar){
                $shadeChar = Read-Host "Enter single char for shade glyph"
            }
            $UIStrings = [PSCustomObject]@{
                block = $blockChar.ToString()
                shade = $shadeChar.ToString()
            }
        }
        else {
            $UIStrings = [PSCustomObject]@{
                block = ([char]9608).tostring()
                shade = ([char]9618).tostring() # 9617 = ░, 9618 = ▒, 9619 = ▓
                #template = (([char]9618).tostring()*100)
            }
        }
            
        if($progress -lt 0){
            $progress = 0
        }elseif($progress -gt 1){
            $progress = 1
        }
        
        if ($width -lt 30) {
            $width = 30
        }
        if (($width -ge $HOST.UI.RawUI.WindowSize.Width) -and !$Headless) {
            $width = $HOST.UI.RawUI.WindowSize.Width - 1
        }

        if ($msgPayload.Length -gt ($width - 2)) {
            $msgPayload = ($msgPayload.substring(0, ($width - 7)) + "[...]")
        }
        

        $BlockCount = [math]::floor(($width * ($progress)))
        $ShadeCount = $width - $BlockCount



        $msgBase = (($UIStrings.block * $BlockCount) + ($UIStrings.shade * $ShadeCount))

        $msgLength = $msgPayload.Length
        $msgIndex = [math]::floor(($width - $msgLength) / 2)
        $msgString = $msgBase.Remove($msgIndex, $msgLength).Insert($msgIndex, $msgPayload)

        Return $msgString
    }
}