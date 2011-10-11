package provide qcode 1.0
package require doc
namespace eval qc {}

proc qc::is_boolean {bool} {
    return [in {Y N YES NO TRUE FALSE T F 0 1} [upper $bool]]
}

proc qc::is_integer {int} {
    if { [string is integer -strict $int] } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_pos {number} {
    if { [is_decimal $number] && $number>=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_pnz {number} {
    if { [is_decimal $number] && $number>0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_non_zero_integer {int} {
    if { [is_integer $int] && $int!=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_non_zero {number} {
    if { [is_decimal $number] && $number!=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_pnz_int { int } {
    # positive non zero integer
    if { [is_integer $int] && $int > 0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_decimal { number } {
    if { [string is double -strict $number]} {
	return 1
    } else {
	return 0
    }
}

proc qc::is_positive_decimal { number } {
    if { [string is double -strict $number] && $number>=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_non_zero_decimal { number } {
    if { [string is double -strict $number] && $number!=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_pnz_decimal { price } {
    # positive non-zero double
    if { [string is double -strict $price] && $price>0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_date { date } {
    # dates are expected to be in iso format 
    return [regexp {^\d{4}-\d{2}-\d{2}$} $date]   
}

proc qc::is_timestamp { date } {
    # timestamps are expected to be in iso format 
    return [regexp {^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$} $date]   
}

proc qc::is_email { email } {
    return [regexp {^[a-zA-Z0-9_\-.]+@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)+$} $email]
}

proc qc::is_postcode { postcode } {
    return [expr [regexp {^[A-Z]{1,2}[0-9]{1,2}[A-Z]? ?[0-9][A-Z][A-Z]$} $postcode] || [regexp {^BFPO ?[0-9]+$} $postcode]]
}

proc qc::is_creditcard { no } {
    regsub -all {[ -]} $no "" no
    set mult 1
    set sum 0
    if { [string length $no]<13 || [string length $no]>19 } {
	return 0
    }
    foreach digit [lreverse [split $no ""]] {
	if { ![is_integer $digit] } {
	    return 0
	}
	set t [expr {$digit*$mult}]
	if { $t >= 10 } {
	    set sum [expr $sum + $t%10 +1]
	} else {
	    set sum [expr $sum + $t]
	}
	if { $mult == 1 } { set mult 2 } else { set mult 1 }
    }
    if { $sum%10 == 0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_creditcard_masked { no } {
    regsub -all {[^0-9\*]} $no "" no

    # 13-19 chars masked with < 6 prefix and < 4 suffix digits
    return [expr [regexp {[0-9\*]{13,19}} $no] && [regexp {^[3-6\*][0-9]{0,5}\*+[0-9]{0,4}$} $no]]
}

proc qc::is_varchar {string length} {
    if { [string length $string]<=$length } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_base64 {string} {
    if { [regexp {^[A-Za-z0-9/+\r\n]+=*$} $string] \
	&& ([string length $string]-[regexp -all -- \r?\n $string])*6%8==0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_int_castable {string} {
    try {
	cast_integer $string
	return true
    } {
	return false
    }
}

proc qc::is_decimal_castable {string} {
    try {
	cast_decimal $string
	return true
    } {
	return false
    }
}

proc qc::is_date_castable {string} {
    try {
	cast_date $string
	return true
    } {
	return false
    }
}

proc qc::is_timestamp_castable {string} {
    try {
	cast_timestamp $string
	return true
    } {
	return false
    }
}

proc qc::is_mobile_number {string} {
    # mobile telephone number
    regsub -all {[^0-9]} $string {} tel_no
    if {  [regexp {^07(5|7|8|9)[0-9]{8}$} $tel_no] } {
	return true
    } else {
	return false
    }
}

proc qc::contains_creditcard {string} {
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
