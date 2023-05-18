proc qc::is::ipv4 {string} {
    #| Checks if the given string follows the IPv4 format.
    # TODO checks structure only, will allow 9999.9999.9999.9999
    if { [regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$} $string] } {
        return 1
    } else {
        return 0
    }
}
