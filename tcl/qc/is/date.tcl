proc qc::is::date {string} {
    #| Checks if the given string is a date.
    #| Dates are expected to be in ISO format.
    if { ! [regexp {^(\d{4})-(\d{2})-(\d{2})$} $string -- yyyy mm dd] } {
        return false
    }
    set yyyy [qc::cast int $yyyy]
    set mm [qc::cast int $mm]
    set dd [qc::cast int $dd]
    if { $mm > 12 || $mm == 0 } {
        return false
    }
    if { $dd == 0 } {
        return false
    }
    if { $mm in {1 3 5 7 8 10 12} } {
        if { $dd > 31 } {
            return false
        }
        return true
    }
    if { $mm in {4 6 9 11} } {
        if { $dd > 30 } {
            return false
        }
        return true
    }
    if { [qc::date_year_is_leap $yyyy] } {
        if { $dd > 29 } {
            return false
        }
        return true
    }
    if { $dd > 28 } {
        return false
    }
    return true
}
