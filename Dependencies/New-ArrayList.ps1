function global:New-ArrayList {

    param(
	  [string][parameter(Mandatory=$false)]$name,
      [switch][parameter(Mandatory=$false)]$overwrite
	)

    process {
        if($PSBoundParameters.ContainsKey('name') -eq $false){
            return New-Object System.Collections.ArrayList
        }else{
            if($overwrite){
                Set-Variable "$name" -Value (new-object System.Collections.ArrayList) -scope "Global"
                write-verbose "Created a new arraylist with the name [$($name)]"
            }else{
                New-Variable "$name" -Value (new-object System.Collections.ArrayList) -scope "Global"
                write-verbose "Created a new arraylist with the name [$($name)]"
            }
        }
    }

}

function global:Add-ToArrayList {
    param(
        [System.Collections.ArrayList][parameter(Mandatory=$true)]$list,
        [parameter(Mandatory=$true)]$object
    )

    process {
        $list.add($object) | Out-Null
        Write-Verbose "Added [$($object)] to [$($list)]"
    }
}

Set-Alias "atal" "Add-ToArrayList"