proc qc::is::mobile_number {string} {
    #| Checks if the given string is of the form of a UK mobile telephone number.
    regsub -all {[^0-9]} $string {} tel_no
    if {  [regexp {^(07[1-57-9][0-9]{8}|07624[0-9]{6})$} $tel_no] } {
        return 1
    } else {
        return 0
    }
}
