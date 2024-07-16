#withFlag ([String]FLAG)
function global:withFlag {
    param(
        [Parameter(Mandatory=$false)]$string,
        [Parameter(Mandatory=$false)]$flagArray,
        [switch][Parameter(Mandatory=$false)]$List,
        [switch][Parameter(Mandatory=$false)]$DoDebug
    )
    process{
        $flagList = New-ArrayList
        if($null -eq $flagArray){$data = $false}
        elseif ($list) {
            foreach ($flag in $flagArray) {
                $flagList.add($flag)>$null
            }
            $data = $flagList
        }
        else {
            $data = ($flagArray -contains $string)
        }
    }
    end{
        return $data
    }
}