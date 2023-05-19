proc qc::is::bigint {int} {
    #| Checks if the given number is a 64-bit signed integer.
    if {[string is wideinteger -strict $int]
        && $int >= -9223372036854775808
        && $int <= 9223372036854775807} {
        return 1
    } else {
        return 0
    }
}
