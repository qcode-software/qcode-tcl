proc qc::is::char {length string} {
    #| Checks if string would fit exactly into a character string of the given length.
    if { [string length $string] == $length } {
        return 1
    } else {
        return 0
    }
}
