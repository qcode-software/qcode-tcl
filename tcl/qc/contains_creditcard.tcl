namespace eval qc {
    namespace export contains_creditcard
}

proc qc::contains_creditcard {string} {
    #| Checks string for occurrences of credit card numbers
    set re {
	(?:^|[^0-9])
	(
	 # amex 15 digits long
	 (?:3\d{3}[ \-\.]*\d{6}[ \-\.]*\d{5})
	 |
	 # other cards 16 digits long
	 (?:[4|5|6]\d{3}[ \-\.]*\d{4}[ \-\.]*\d{4}[ \-\.]*\d{4})
	 )
	(?:[^0-9]|$)
    }
    foreach {match cc_no} [regexp -inline -all -expanded $re $string] {
	if { [is_creditcard [string map {" " "" - "" . ""} $cc_no]] } {
	    return true
	}
    }
    return false
}
