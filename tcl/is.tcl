namespace eval qc {
    namespace export is_* contains_creditcard
}

proc qc::is_boolean {bool} {
    return [in {Y N YES NO TRUE FALSE T F 0 1} [upper $bool]]
}

proc qc::is_integer {int} {
    #| Deprecated - see qc::is integer
    return [qc::is integer $int]
}

proc qc::is_integer_old {int} {
    if { [string is integer -strict $int] && $int >= -2147483648 && $int <= 2147483647 } {
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

proc qc::is_email { email } {
    return [regexp {^[a-zA-Z0-9_\-]+([\.\+][a-zA-Z0-9_\-]+)*@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)+$} $email]
}

proc qc::is_postcode { postcode } {
    # uk postcode
    return [expr [regexp {^[A-Z]{1,2}[0-9R][0-9A-Z]? [0-9][ABD-HJLNP-UW-Z]{2}$} $postcode] || [regexp {^BFPO ?[0-9]+$} $postcode]]
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

proc qc::is_creditcard_masked { no } {
    #| Check the credit card number is masked to PCI requirements
    regsub -all {[^0-9\*]} $no "" no

    # 13-19 chars masked with < 6 prefix and < 4 suffix digits
    return [expr [regexp {[0-9\*]{13,19}} $no] && [regexp {^[3-6\*][0-9]{0,5}\*+[0-9]{0,4}$} $no]]
}

proc qc::is_varchar {string length} {
    #| Checks string would fit in a varchar of length $length
    if { [string length $string]<=$length } {
	return 1
    } else {
	return 0
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

proc qc::is_int_castable {string} {
    #| Can input be cast to an integer?
    qc::try {
	cast_integer $string
	return true
    } {
	return false
    }
}

proc qc::is_decimal_castable {string} {
    qc::try {
	qc::cast_decimal $string
	return true
    } {
	return false
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

proc qc::is_timestamp_castable {string} {
    #| Can string be cast into timestamp format?
    qc::try {
	cast_timestamp $string
	return true
    } {
	return false
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

proc qc::is_hex {string} {
    #| Does the input look like a hex number?
    return [regexp -nocase {^[0-9a-f]*$} $string]
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

proc qc::is_ipv4 {string} {
    # TODO checks structure only, will allow 9999.9999.9999.9999
    if { [regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$} $string] } {
        return true
    } else {
        return false
    }
}

proc qc::is_cidrnetv4 {string} {
    if { [regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$} $string] } {
        return true
    } else {
        return false
    }
}

proc qc::is_uri_valid {uri} {
    #| Test if the given uri is valid according to rfc3986 (https://tools.ietf.org/html/rfc3986)
  
    set unreserved {
        (?:[a-zA-Z0-9\-._~])
    }
    
    set sub_delims {
        (?:[!$&'()*+,;=])
    }
    
    set pct_encoded {
        (?:%[0-9a-fA-F]{2})
    }

    set pchar [subst -nocommands -nobackslashes {
        (?:${unreserved}|${pct_encoded}|${sub_delims}|[:@])
    }]
    
    set segment [subst -nocommands -nobackslashes {
        (?:${pchar}*)
    }]

    set segment_nz [subst -nocommands -nobackslashes {
        (?:${pchar}+)
    }]
    
    set segment_nz_nc [subst -nocommands -nobackslashes {
        (?:(?:${unreserved}|${pct_encoded}|${sub_delims}|[@])+)
    }]    

    set scheme {
        (?:[a-zA-Z][a-zA-Z+\-.]*)
    }

    set dec_octet {
        (?:[0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])
    }
    
    set ipv4_address [subst -nocommands -nobackslashes {
        (?:${dec_octet}\.${dec_octet}\.${dec_octet}\.${dec_octet})
    }]

    set h16 {
        (?:[0-9a-fA-F]{1,4})
    }

    set ls32 [subst -nocommands -nobackslashes {
        (?:
         ${h16}:${h16}
         |
         ${ipv4_address}
         )
    }]

    set ipv6_address [subst -nocommands -nobackslashes {
        (?:
         (?:${h16}:){6}${ls32}
         |
         ::(?:${h16}:){5}${ls32}
         |
         (?:${h16})?::(?:${h16}:){4}${ls32}
         |
         (?:(?:${h16}:)?${h16})?::(?:${h16}:){3}${ls32}
         |
         (?:(?:${h16}:){0,2}${h16})?::(?:${h16}:){2}${ls32}
         |
         (?:(?:${h16}:){0,3}${h16})?::${h16}:${ls32}
         |
         (?:(?:${h16}:){0,4}${h16})?::${ls32}
         |
         (?:(?:${h16}:){0,5}${h16})?::${h16}
         |
         (?:(?:${h16}:){0,6}${h16})?::
         )
    }]

    set ipvfuture [subst -nocommands -nobackslashes {
        (?:v[0-9a-fA-F]+\.(?:${unreserved}|${sub_delims}|:)+)
    }]
    
    set ip_literal [subst -nocommands -nobackslashes {
        (?:\[(?:${ipv6_address}|${ipvfuture})\])
    }]
    
    set host [subst -nocommands -nobackslashes {
        (?:${ip_literal}|${ipv4_address}|(?:${unreserved}|${pct_encoded}|${sub_delims})*)
    }]

    set user_info [subst -nocommands -nobackslashes {
        (?:(?:${unreserved}|${pct_encoded}|${sub_delims}|:)*)
    }]

    set port [subst -nocommands -nobackslashes {
        (?:[0-9]*)
    }]

    set authority [subst -nocommands -nobackslashes {
        (?:${user_info}@)?${host}(?::${port})?
    }]           

    set path_abempty [subst -nocommands -nobackslashes {
        (?:(?:/${segment})*)
    }]
    
    set path_absolute [subst -nocommands -nobackslashes {
        (?:/(?:${segment_nz}(?:/${segment})*)?)
    }]
    
    set path_noscheme [subst -nocommands -nobackslashes {
        (?:${segment_nz_nc}(?:/${segment})*)
    }]

    set path_rootless [subst -nocommands -nobackslashes {
        (?:${segment_nz}(?:/${segment})*)
    }]

    set path_empty [subst -nocommands -nobackslashes {
        (?:${pchar}{0})
    }]

    set fragment_char [subst -nobackslashes {
        (?:${pchar}|/|\?)
    }]

    set query_char [subst -nobackslashes {
        (?:${pchar}|/|\?)
    }]   
    
    set relative_uri [subst -nocommands -nobackslashes {
        (?:
         (?://${authority}${path_abempty}|${path_absolute}|${path_noscheme}|${path_empty})
         (?:\?${query_char}+)?
         (\#${fragment_char}+)?
         )
    }]

    set absolute_uri [subst -nocommands -nobackslashes {
        (?:
         ${scheme}:
         (?:(?://${authority}${path_abempty})|${path_absolute}|${path_rootless}|${path_empty})
         (?:\?${query_char}+)?
         (?:\#${fragment_char}+)?
         )
    }]

    set re [subst -nocommands -nobackslashes {
        ^
        (?:
         ${absolute_uri}
         |
         ${relative_uri}
         )
        $
    }]
    
    return [regexp -expanded $re $uri]
}

namespace eval qc::is {
    namespace export integer
    namespace ensemble create
    
    proc integer {int} {
        #| Checks if the given number is a 32-bit signed integer.
        if {[string is integer -strict $int] && $int >= -2147483648 && $int <= 2147483647} {
            return 1
        } else {
            return 0
        }
    }
}
