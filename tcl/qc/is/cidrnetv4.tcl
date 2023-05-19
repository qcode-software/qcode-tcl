proc qc::is::cidrnetv4 {string} {
    #| Checks if the given string follows the CIDR NETv4 format.
    if { [regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$} $string] } {
        return 1
    } else {
        return 0
    }
}
