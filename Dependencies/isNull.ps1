#isNull check
function global:isNullOrEmpty {
    param(
        [parameter(Mandatory = $false,ValueFromPipeline = $true)]$data
    )

    end{
        $nullCHK = $false
        if ($null -eq $data) {$nullCHK = $true}
        if ("" -eq $data) {$nullCHK = $true}
        return ($nullCHK)
    }
}

Set-Alias "isNull" isNullOrEmpty -Scope Global