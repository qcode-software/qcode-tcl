proc qc::is::integer {int} {
    #| Checks if the given number is a 32-bit signed integer.
    if {[string is integer -strict $int]
        && $int >= -2147483648 && $int <= 2147483647} {
        return 1
    } else {
        return 0
    }
}
