#Stolen from web :D
function global:DisplayInBytes($num) {
    $suffix = "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"
    $index = 0
    while ($num -gt 1kb) {
        $num = $num / 1kb
        $index++
    } 

    return "$("{0:N2} {1}" -f $num, $suffix[$index])"
}