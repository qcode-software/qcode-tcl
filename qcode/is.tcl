package provide qcode 2.1
package require doc
namespace eval qc {}

proc qc::is_boolean {bool} {
    return [in {Y N YES NO TRUE FALSE T F 0 1} [upper $bool]]
}

doc qc::is_boolean {
    Examples {
        % qc::is_boolean true
        1
        % qc::is_boolean yes
        1
        % qc::is_boolean churches
        0
        % qc::is_boolean 1
        1
        % qc::is_boolean 99
        0
    }
}

proc qc::is_integer {int} {
    if { [string is integer -strict $int] } {
	return 1
    } else {
	return 0
    }
}

doc qc::is_integer {
    Examples {
        % qc::is_integer 999
        1
        % qc::is_integer 0.1
        0
        % qc::is_integer 0
        1
        % qc::is_integer true
        0
    }
}

proc qc::is_pos {number} {
    if { [is_decimal $number] && $number>=0 } {
	return 1
    } else {
	return 0
    }
}

doc qc::is_pos {
    Examples {
        % qc::is_pos 1
        1
        % qc::is_pos -1
        0
        % qc::is_pos 0
        1
        % qc::is_pos cats
        0
    }
}

proc qc::is_pnz {number} {
    if { [is_decimal $number] && $number>0 } {
	return 1
    } else {
	return 0
    }
}

doc qc::is_pnz {
    Examples {
        % qc::is_pnz 1
        1
        % qc::is_pnz -1
        0
        % qc::is_pnz 0
        0
        % qc::is_pnz cats
        0
    }
}

proc qc::is_non_zero_integer {int} {
    if { [is_integer $int] && $int!=0 } {
	return 1
    } else {
	return 0
    }
}

doc qc::is_non_zero_integer {
    Examples {
        % qc::is_non_zero_integer 0
        0
        % qc::is_non_zero_integer -34
        1
    }
}

proc qc::is_non_zero {number} {
    if { [is_decimal $number] && $number!=0 } {
	return 1
    } else {
	return 0
    }
}

doc qc::is_non_zero {
    Examples {
        % qc::is_non_zero 99
        1
        % qc::is_non_zero 0.0000001
        1
        % qc::is_non_zero 0
        0
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

doc qc::is_pnz_int {
    Examples {
        % qc::is_pnz_int 10
        1
        % qc::is_pnz_int 10.5
        0
        % qc::is_pnz_int 0
        0
    }
}

proc qc::is_decimal { number } {
    if { [string is double -strict $number]} {
	return 1
    } else {
	return 0
    }
}

doc qc::is_decimal {
    Examples {
        % qc::is_decimal 1A
        0
        % qc::is_decimal 9.999999
        1
    }
}

proc qc::is_positive_decimal { number } {
    if { [string is double -strict $number] && $number>=0 } {
	return 1
    } else {
	return 0
    }
}
doc qc::is_positive_decimal {
    Examples {
        % qc::is_positive_decimal -9.99999
        0
        % qc::is_positive_decimal 0.000001
        1
    }
}

doc qc::is_positive_decimal {
    Examples {
        % qc::is_positive_decimal -9.99999
        0
        % qc::is_positive_decimal 0.000001
        1
    }
}

proc qc::is_non_zero_decimal { number } {
    if { [string is double -strict $number] && $number!=0 } {
	return 1
    } else {
	return 0
    }
}

doc qc::is_non_zero_decimal {
    Examples {
        % qc::is_non_zero_decimal -9.99999
        1
        %  qc::is_non_zero_decimal 0
        0
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

doc qc::is_pnz_decimal {
    Examples {
        % qc::is_pnz_decimal 0
        0
        % qc::is_pnz_decimal -9.99
        0
        % qc::is_pnz_decimal 1
        1
    }
}

proc qc::is_date { date } {
    # dates are expected to be in iso format 
    return [regexp {^\d{4}-\d{2}-\d{2}$} $date]   
}

doc qc::is_date {
    Examples {
        % qc::is_date 12/12/12
        0
        % qc::is_date 12:38:00
        0
        % qc::is_date 2012-08-12
        1
    }
}

proc qc::is_timestamp_http { date } {
    #| Returns true if date is an acceptable HTTP timestamp. Note although all three should be accepted,
    #| only RFC 1123 format should be generated.
    # RFC 1123 - Sun, 06 Nov 1994 08:49:37 GMT
    if { [regexp {([(Mon)|(Tue)|(Wed)|(Thu)|(Fri)|(Sat)|(Sun)][,]\s\d{2}\s(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s\d{4}\s[0-2]\d(\:)[0-5]\d(\:)[0-5]\d\s(GMT))} $date] } {
        return 1
    }
    # RFC 850 - Sunday, 06-Nov-94 08:49:37 GMT
    if { [regexp {([(Monday)|(Tuesday)|(Wednesday)|(Thursday)|(Friday)|(Saturday)|(Sunday)][,]\s\d{2}-(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)-\d{2}\s[0-2]\d(\:)[0-5]\d(\:)[0-5]\d\s(GMT))} $date] } {
        return 1
    }
    # ANCI C - Sun Nov  6 08:49:37 1994
    if { [regexp {([(Mon)|(Tue)|(Wed)|(Thu)|(Fri)|(Sat)|(Sun)]\s(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s(\s|\d)\d\s[0-2]\d(\:)[0-5]\d(\:)[0-5]\d \d{4})} $date] } {
        return 1
    }
    return 0
}

proc qc::is_timestamp { date } {
    # timestamps are expected to be in iso format 
    return [regexp {^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$} $date]   
}

doc qc::is_timestamp {
    Examples {
        %  qc::is_timestamp 2012-01-01
        0
        % qc::is_timestamp {2012-01-01 12:12:12}
        1
    }
}

proc qc::is_email { email } {
    return [regexp {^[a-zA-Z0-9_\-]+(\.[a-zA-Z0-9_\-]+)*@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)+$} $email]
}

doc qc::is_email {
    Examples {
        % qc::is_email @gmail.com
        0
        % qc::is_email dave.@gmail.com
        0
        % qc::is_email dave@gmail
        0
        % qc::is_email dave.smith@gmail.co.uk
        1
    }
}

proc qc::is_postcode { postcode } {
    # uk postcode
    return [expr [regexp {^[A-Z]{1,2}[0-9R][0-9A-Z]? [0-9][ABD-HJLNP-UW-Z]{2}$} $postcode] || [regexp {^BFPO ?[0-9]+$} $postcode]]
}

doc qc::is_postcode {
    Examples {
        % qc::is_postcode EH3
        0
        % qc::is_postcode "BFPO 61"
        1
        % qc::is_postcode "EH3 9EE"
        1
    }
}

proc qc::is_creditcard { no } {
    #| Checks if no is an allowable credit card number
    #| Checks, number of digits are >13 & <19, all characters are integers, luhn 10 check
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
	    set sum [expr {$sum + $t%10 +1}]
	} else {
	    set sum [expr {$sum + $t}]
	}
	if { $mult == 1 } { set mult 2 } else { set mult 1 }
    }
    if { $sum%10 == 0 } {
	return 1
    } else {
	return 0
    }
}

doc qc::is_creditcard {
    Examples {
        % qc::is_creditcard 4111111111111111
        1
        % qc::is_creditcard 4111111111111112
        0
        % qc::is_creditcard 41
        0
        % qc::is_creditcard 41111111i1111111
        0
    }
}

proc qc::is_creditcard_masked { no } {
    #| Check the credit card number is masked to PCI requirements
    regsub -all {[^0-9\*]} $no "" no

    # 13-19 chars masked with < 6 prefix and < 4 suffix digits
    return [expr [regexp {[0-9\*]{13,19}} $no] && [regexp {^[3-6\*][0-9]{0,5}\*+[0-9]{0,4}$} $no]]
}

doc qc::is_creditcard_masked {
    Examples {
        % qc::is_creditcard_masked 4111111111111111
        0
        % qc::is_creditcard_masked 411111****111111
        0
        % qc::is_creditcard_masked 411111******1111
        1
        % qc::is_creditcard_masked 411111**********
        1
    }
}

proc qc::is_varchar {string length} {
    #| Checks string would fit in a varchar of length $length
    if { [string length $string]<=$length } {
	return 1
    } else {
	return 0
    }
}

doc qc::is_varchar {
    Examples {
        % qc::is_varchar "Too long string" 14
        0
        % qc::is_varchar "Small Enough" 14
        1
    }
}

proc qc::is_base64 {string} {
    #| Checks input has only allowable base64 characters and is of the correct format
    if { [regexp {^[A-Za-z0-9/+\r\n]+=*$} $string] \
	&& ([string length $string]-[regexp -all -- \r?\n $string])*6%8==0 } {
	return 1
    } else {
	return 0
    }
}

doc qc::is_base64 {
    Examples {
        % qc::is_base64 RG9sbHkgUGFydG9uCg==
        1
        % qc::is_base64 RG9sbHkgUGFydG9uCg
        0
        % qc::is_base64 RG9sbHkgUGFydG9uCg=
        0
        % qc::is_base64 ^^RG9sbHkgUGFydG9uCg
        0
    }
}

proc qc::is_int_castable {string} {
    #| Can input be cast to an integer?
    qc::try {
	cast_integer $string
	return true
    } {
	return false
    }
}

doc qc::is_int_castable {
    Examples {
        % qc::is_int_castable 43e2
        true
        % qc::is_int_castable  2.366%
        true
        % qc::is_int_castable 2,305
        true
        % qc::is_int_castable rolex
        false
    }
}

proc qc::is_decimal_castable {string} {
    qc::try {
	cast_decimal $string
	return true
    } {
	return false
    }
}

doc qc::is_decimal_castable {
    Examples {
        % qc::is_decimal_castable 2,305.25
        true
        % qc::is_decimal_castable 2.366%
        true
        % qc::is_decimal_castable 1A
        false
    }
}

proc qc::is_date_castable {string} {
    #| Can string be cast into date format?
    qc::try {
	cast_date $string
	return true
    } {
	return false
    }
}

doc qc::is_date_castable {
    Examples {
        % qc::is_date_castable 10
        true
        % qc::is_date_castable "June 22nd"
        true
        % qc::is_date_castable tomorrow
        true
        % qc::is_date_castable May
        false
    }
}

proc qc::is_timestamp_castable {string} {
    #| Can string be cast into timestamp format?
    qc::try {
	cast_timestamp $string
	return true
    } {
	return false
    }
}

doc qc::is_timestamp_castable {
    Examples {
        % qc::is_timestamp_castable today
        true
        % qc::is_timestamp_castable 12/5/12
        true
        % qc::is_timestamp_castable Mary
        false
    }
}

proc qc::is_mobile_number {string} {
    # uk mobile telephone number
    regsub -all {[^0-9]} $string {} tel_no
    if {  [regexp {^07(5|7|8|9)[0-9]{8}$} $tel_no] } {
	return true
    } else {
	return false
    }
}

doc qc::is_mobile_number {
    Examples {
        % qc::is_mobile_number " 0 7  986 21299     9"
        true
        % qc::is_mobile_number 09777112112
        false
        % qc::is_mobile_number 013155511111
        false
        % qc::is_mobile_number 07512122122
        true
    }
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

doc qc::contains_creditcard {
    Examples {
        % qc::contains_creditcard "This is a string with a CC number 4111111111111111 in it."
        true
        % qc::contains_creditcard "There's just a phone number here 01311111111 so nothing to see"
        false
        % qc::contains_creditcard "It won't be fooled by CC-like numbers due to the luhn 10 check 4111111111111112"
        false
    }
}

proc qc::is_hex {string} {
    #| Does the input look like a hex number?
    return [regexp -nocase {^[0-9a-f]*$} $string]
}

doc qc::is_hex {
    Examples {
        %  qc::is_hex 9F
        1
        %  qc::is_hex 1a
        1
        %  qc::is_hex 9G
        0
        % qc::is_hex 9FFFFFF
        1
    }
}

proc qc::is_url {args} {
    #| This is a more restrictive subset of all legal uri's defined by RFC 3986
    #| Relax as needed
    args $args -relative -- url
    default relative false
    if { $relative } {
        return [regexp -expanded {
            # path
            ^([a-zA-Z0-9_\-\.~+/%]+)?
            # query
            (\?[a-zA-Z0-9_\-\.~+/%=&]+)?
            # anchor
            (\#[a-zA-Z0-9_\-\.~+/%]+)?
            $
        } $url]
    } else {
        return [regexp -expanded {
            # protocol
            ^https?://
            # domain
            [a-z0-9\-\.]+
            # port
            (:[0-9]+)?
            # path
            ([a-zA-Z0-9_\-\.~+/%]+)?
            # query
            (\?[a-zA-Z0-9_\-\.~+/%=&]+)?
            # anchor
            (\#[a-zA-Z0-9_\-\.~+/%]+)?
            $
        } $url]
    }
}

doc qc::is_url {
    Examples {
        % qc::is_url www.google.com
        0
        % qc::is_url http://www.google.co.uk
        1
        % qc::is_url https://www.google.co.uk:443/subdir?formvar1=foo&formvar2=bar#anchor 
        1
    }
}

proc qc::is_ipv4 {string} {
    # TODO checks structure only, will allow 9999.9999.9999.9999
    if { [regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$} $string] } {
        return true
    } else {
        return false
    }
}

doc qc::is_ipv4 {
    Examples {
        % qc::is_ipv4  2001:0db8:85a3:0042:0000:8a2e:0370:7334
        false
        % qc::is_ipv4 192.0.1
        false
        % qc::is_ipv4 192.168.1.1
        true
    }
}

proc qc::is_cidrnetv4 {string} {
    if { [regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$} $string] } {
        return true
    } else {
        return false
    }
}

doc qc::is_cidrnetv4 {
    Examples {
        % qc::is_cidrnetv4 192.168.1.1
        false
        % qc::is_cidrnetv4 192.168.1.0/24
        true
    }
}
