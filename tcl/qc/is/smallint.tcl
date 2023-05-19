proc qc::is::smallint {int} {
    #| Checks if the given number is an 8-bit signed integer.
    if {[string is integer -strict $int] && $int >= -32768 && $int <= 32767} {
        return 1
    } else {
        return 0
    }
}
