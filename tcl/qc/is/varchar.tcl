proc qc::is::varchar {length string} {
    #| Checks if string would fit in a varchar of the given length.
    if { $length eq "" } {
        # PostgreSQL specification - missing length means any size
        return 1
    } elseif { [string length $string] <= $length } {
        return 1
    } else {
        return 0
    }
}
