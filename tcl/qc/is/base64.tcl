proc qc::is::base64 {string} {
    #| Checks if the given string has only allowable base64 characters and is of the
    #| correct format.
    if { [regexp {^[A-Za-z0-9/+\r\n]+=*$} $string] \
             && ([string length $string]-[regexp -all -- \r?\n $string])*6%8==0 } {
        return 1
    } else {
        return 0
    }
}
