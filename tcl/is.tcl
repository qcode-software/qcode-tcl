namespace eval qc {
    namespace export is_* contains_creditcard
}

proc qc::is_boolean {bool} {
    #| Deprecated - see qc::is boolean
    return [qc::is boolean $bool]
}

proc qc::is_integer {int} {
    #| Deprecated - see qc::is integer
    return [qc::is integer $int]
}

proc qc::is_pos {number} {
    #| Deprecated
    if { [is_decimal $number] && $number>=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_pnz {number} {
    #| Deprecated
    if { [is_decimal $number] && $number>0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_non_zero_integer {int} {
    #| Deprecated
    if { [is_integer $int] && $int!=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_non_zero {number} {
    #| Deprecated
    if { [is_decimal $number] && $number!=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_pnz_int { int } {
    #| Deprecated
    # positive non zero integer
    if { [is_integer $int] && $int > 0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_decimal { number } {
    #| Deprecated - see qc::is decimal
    return [qc::is decimal $number]
}

proc qc::is_positive_decimal { number } {
    #| Deprecated
    if { [string is double -strict $number] && $number>=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_non_zero_decimal { number } {
    #| Deprecated
    if { [string is double -strict $number] && $number!=0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_pnz_decimal { price } {
    #| Deprecated
    # positive non-zero double
    if { [string is double -strict $price] && $price>0 } {
	return 1
    } else {
	return 0
    }
}

proc qc::is_date { date } {
    #| Deprecated - see qc::is date
    # dates are expected to be in iso format 
    return [qc::is date $date] 
}

proc qc::is_timestamp_http { date } {
    #| Deprecated - see qc::is timestamp_http
    #| Returns true if date is an acceptable HTTP timestamp. Note although all three should be accepted,
    #| only RFC 1123 format should be generated.
    # RFC 1123 - Sun, 06 Nov 1994 08:49:37 GMT
    return [qc::is timestamp_http $date]
}

proc qc::is_timestamp { date } {
    #| Deprecated - see qc::is timestamp
    # timestamps are expected to be in iso format 
    return [qc::is timestamp $date]
}

proc qc::is_email { email } {
    #| Deprecated - see qc::is email
    return [qc::is email $email]
}

proc qc::is_postcode { postcode } {
    #| Deprecated - see qc::is postcode
    # uk postcode
    return [qc::is postcode $postcode]
}

proc qc::is_creditcard { no } {
    #| Deprecated - see qc::is creditcard
    #| Checks if no is an allowable credit card number
    #| Checks, number of digits are >13 & <19, all characters are integers, luhn 10 check
    return [qc::is creditcard $no]
}

proc qc::is_creditcard_masked { no } {
    #| Deprecated - see qc::is creditcard_masked
    #| Check the credit card number is masked to PCI requirements
    return [qc::is creditcard_masked $no]
}

proc qc::is_varchar {string length} {
    #| Deprecated - see qc::is varchar
    #| Checks string would fit in a varchar of length $length
    return [qc::is varchar $length $string]
}

proc qc::is_base64 {string} {
    #| Deprecated - see qc::is base64
    #| Checks input has only allowable base64 characters and is of the correct format
    return [qc::is base64 $string]
}

proc qc::is_int_castable {string} {
    #| Deprecated - see qc::castable integer
    #| Can input be cast to an integer?
    return [qc::castable integer $string]
}

proc qc::is_decimal_castable {string} {
    #| Deprecated - see qc::castable decimal
    return [qc::castable decimal $string]
}

proc qc::is_date_castable {string} {
    #| Deprecated - see qc::castable date
    #| Can string be cast into date format?
    return [qc::castable date $string]
}

proc qc::is_timestamp_castable {string} {
    #| Deprecated - see qc::castable timestamp
    #| Can string be cast into timestamp format?
    return [qc::castable timestamp $string]
}

proc qc::is_mobile_number {string} {
    #| Deprecated - see qc::is mobile_number
    # uk mobile telephone number
    return [qc::is mobile_number $string]
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
    #| Deprecated - see qc::is hex
    #| Does the input look like a hex number?
    return [qc::is hex $string]
}

proc qc::is_url {args} {
    #| Deprecated - see qc::is url
    #| This is a more restrictive subset of all legal uri's defined by RFC 3986
    #| Relax as needed
    return [qc::is url {*}$args]
}

proc qc::is_ipv4 {string} {
    #| Deprecated - see qc::is ipv4
    # TODO checks structure only, will allow 9999.9999.9999.9999
    return [qc::is ipv4 $string]
}

proc qc::is_cidrnetv4 {string} {
    #| Deprecated - see qc::is cidrnetv4
    return [qc::is cidrnetv4 $string]
}

proc qc::is_uri_valid {uri} {
    #| Deprecated - see qc::is uri
    #| Test if the given uri is valid according to rfc3986 (https://tools.ietf.org/html/rfc3986)
    return [qc::is uri $uri]
}

namespace eval qc::is {
    
    namespace export integer smallint bigint boolean decimal timestamp timestamptz char varchar enumeration text domain safe_html safe_markdown date timestamp_http email postcode creditcard creditcard_masked period base64 hex mobile_number ipv4 cidrnetv4 url uri url_path time interval
    namespace ensemble create -unknown {
        data_type_parser
    }
    
    proc integer {int} {
        #| Checks if the given number is a 32-bit signed integer.
        if {[string is integer -strict $int] && $int >= -2147483648 && $int <= 2147483647} {
            return 1
        } else {
            return 0
        }
    }

    proc smallint {int} {
        #| Checks if the given number is an 8-bit signed integer.
        if {[string is integer -strict $int] && $int >= -32768 && $int <= 32767} {
            return 1
        } else {
            return 0
        }
    }

    proc bigint {int} {
        #| Checks if the given number is a 64-bit signed integer.
        if {[string is wideinteger -strict $int] && $int >= -9223372036854775808 && $int <= 9223372036854775807} {
            return 1
        } else {
            return 0
        }
    }

    proc boolean {bool} {
        #| Checks if the given number is a boolean.
        return [expr {[string toupper $bool] in {Y N YES NO TRUE FALSE T F 0 1}}]
    }

    proc decimal {args} {
        #| Checks if the given number is a decimal.
        qc::args $args -precision ? -scale ? -- string
        if {[string is double -strict $string]} {
            if { ! [info exists precision] && ! [info exists scale] } {
                # Scale and precision not given.
                return 1
            } elseif { ! [info exists precision] && [info exists scale] } {
                # Scale given but not precision.
                return -code error "Precision must be provided with scale."
            } elseif { [info exists precision] } {
                # Precision given.
                if { $precision <= 0 || ! [qc::is integer $precision]} {
                    return -code error "Precision must be a positive integer."
                }
                # Count the number of digits before and after the decimal point.
                set number [qc::exp2string $string]
                set parts [split $number .]
                set left_count [string length [lindex $parts 0]]
                set right_count [string length [lindex $parts 1]]
                if { $left_count == 0 } {
                    # The leading zero wasn't given.
                    return -code error "Incomplete numeric string."
                }

                set total_count [expr {$left_count + $right_count}]
                if { $precision < $total_count } {
                    # Precision is less than the total number of digits in the given decimal.
                    return 0
                }
                
                if { ! [info exists scale] } {
                    # Scale wasn't given so set it to 0.
                    set scale 0
                }

                if { $scale < 0 || ! [qc::is integer $scale]} {
                    return -code error "Scale must be a non-negative integer."
                }

                set left_digit_max [expr {$precision - $scale}]
                if { $left_count > $left_digit_max || $right_count > $scale } {
                    return 0
                } else {
                    return 1
                }
                
            }
        } else {
            return 0
        }
    }

    proc timestamp { date } {
        #| Checks if the given date is a timestamp (in iso format).
        return [regexp {^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$} $date]   
    }

    proc timestamptz {date} {
        #| Checks if the given date is a timestamp with a time zone (in iso format).
        return [regexp {^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}(\+|-)([0-9][0-9])$} $date] 
    }

    proc char {length string} {
        #| Checks if string would fit exactly into a character string of the given length.
        if { [string length $string] == $length } {
            return 1
        } else {
            return 0
        }
    }

    proc varchar {length string} {
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

    proc enumeration {enum_name value} {
        #| Checks if the given value is a value in enumeration enum_name.
        if {[qc::memoize qc::db_enum_exists $enum_name] && $value in [qc::memoize qc::db_enum_values $enum_name]} {
            return 1
        } else {
            return 0
        }
    }

    proc text {string} {
        #| Check if the given string is text
        return 1
    }

    proc domain {domain_name value} {
        #| Checks if the given value falls under the domain domain_name.
        if {[qc::memoize qc::db_domain_exists $domain_name]} {
            set base_type [qc::memoize qc::db_domain_base_type $domain_name]
            if { ! [qc::is $base_type $value] } {
                return 0
            }
            set constraints [qc::memoize qc::db_domain_constraints $domain_name]
            dict for {constraint_name check_clause} $constraints {
                if { ! [qc::db_eval_domain_constraint $value $base_type $check_clause] } {
                    return 0
                }
            }
            return 1
        }
        return 0
    }

    proc safe_html {text} {
        #| Checks if the given text contains only safe html.
        try {
            # wrap the text up in <root> to preserve text outwith the html
            set text [qc::h root $text]
            set doc [dom parse -html $text]
            set root [$doc documentElement]
            
            if {$root eq ""} {
                $doc delete
                return 1
            } else {
                set safe [expr {[qc::safe_elements_check $root] && [qc::safe_attributes_check $root]}]
                $doc delete
                return $safe
            }
        } on error [list error_message options] {
            return 0
        }
    }

    proc safe_markdown {markdown} {
        #| Checks if the given markdown text contains HTML elements that are deemed safe.
        try {
            qc::commonmark2html $markdown
            return 1
        } on error [list error_message options] {
            return 0
        }
    }

    proc date {string} {
        #| Checks if the given string is a date.
        #| Dates are expected to be in ISO format.
        return [regexp {^\d{4}-\d{2}-\d{2}$} $string]
    }

    proc timestamp_http {date} {
        #| Checks if the given date is an acceptable HTTP timestamp. Note although all three should be accepted,
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

    proc time {time} {
        #| Check if the given date is a time
        #| in the form 23:59:59 or 23:59:59.01
        return [regexp {^(([0-1][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]|24:00:00)(\.\d{1,6})?$} $time]
    }

    proc email {email} {
        #| Checks if the given string follows the form of an email address.
        return [regexp {^[a-zA-Z0-9_\-]+([\.\+][a-zA-Z0-9_\-]+)*@[a-zA-Z0-9\-]+(\.[a-zA-Z0-9\-]+)+$} $email]
    }

    proc postcode {postcode} {
        #| Checks if the given string is a UK postcode.
        return [expr [regexp {^[A-Z]{1,2}[0-9R][0-9A-Z]? [0-9][ABD-HJLNP-UW-Z]{2}$} $postcode] || [regexp {^BFPO ?[0-9]+$} $postcode]]
    }

    proc creditcard {number} {
        #| Checks if the given string is an allowable credit card number.
        #| Checks, number of digits are >13 & <19, all characters are integers, luhn 10 check
        regsub -all {[ -]} $number "" number
        set mult 1
        set sum 0
        if { [string length $number]<13 || [string length $number]>19 } {
            return 0
        }
        foreach digit [lreverse [split $number ""]] {
            if { ![qc::is integer $digit] } {
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

    proc creditcard_masked {string} {
        #| Check the credit card number is masked to PCI requirements.
        regsub -all {[^0-9\*]} $string "" number

        # 13-19 chars masked with < 6 prefix and < 4 suffix digits
        return [expr [regexp {[0-9\*]{13,19}} $number] && [regexp {^[3-6\*][0-9]{0,5}\*+[0-9]{0,4}$} $number]]
    }

    proc period {string} {
        #| Check if the given string is a period.
        set month_names [list Jan January Feb February Mar March Apr April May Jun June Jul July Aug August Sep September Oct October Nov November Dec December]
        set regexp_map [list \$month_names_regexp [join $month_names |]]

        if { [regexp -nocase {^\s*(.*?)\s+to\s+(.*?)\s*$} $string -> period1 period2] } {
            # Period defined by two periods eg "Jan 2011 to March 2011"
            if { [qc::is period $period1] && [qc::is period $period2] } {
                return 1
            } else {
                return 0
            }

        } elseif { [qc::is date $string] } {
            # String is an iso date eg "2014-01-01"
            return 1

        } elseif { [regexp {^([12]\d{3})$} $string -> year] } {
            # Exact match for year eg "2006"
            return 1

        } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)\s+([12]\d{3})$}] $string -> month_name year] } {
            # Exact match in format "Jan 2006"
            return 1

        } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)$}] $string -> month_name] } {
            # Exact match in format "Jan" (assume current year)
            return 1

        } elseif { [regexp -nocase -- [string map $regexp_map {^([0-9]{1,2})(?:st|th|nd|rd)?\s+($month_names_regexp)\s+([12]\d{3})$}] $string -> dom month_name year] } {
            # Exact match for castable date in format "1st Jan 2014"
            return 1

        } elseif { [regexp -nocase -- [string map $regexp_map {^([0-9]{1,2})(?:st|th|nd|rd)?\s+($month_names_regexp)$}] $string -> dom month_name] } {
            # Exact match for castable date in format "1st Jan" (assume current year)
            return 1       

        } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)\s+([0-9]{1,2})(?:st|th|nd|rd)?\s+([12]\d{3})$}] $string -> month_name dom year] } {
            # Exact match for castable date in format "Jan 1st 2014"
            return 1

        } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)\s+([0-9]{1,2})(?:st|th|nd|rd)?$}] $string -> month_name dom] } {
            # Exact match for castable date in format "Jan 1st" (assume current year)
            return 1

        } else {
            # could not parse string
            return 0
        }

        if { [regexp -nocase {^\s*(.*?)\s+to\s+(.*?)\s*$} $string -> period1 period2] } {
            # Period defined by two periods eg "Jan 2011 to March 2011"
            if { [qc::is period $period1] && [qc::is period $period2] } {
                return 1
            } else {
                return 0
            }

        } elseif { [qc::is date $string] } {
            # String is an iso date eg "2014-01-01"
            return 1

        } elseif { [regexp {^([12]\d{3})$} $string -> year] } {
            # Exact match for year eg "2006"
            return 1

        } elseif { [regexp -nocase -- {^([0-9]+)(?:st|th|nd|rd)?\s+(Jan|January|Feb|February|Mar|March|Apr|April|May|Jun|June|Jul|July|Aug|August|Sep|September|Oct|October|Nov|November|Dec|December)(?:\s+([12]\d{3}))?$} $string -> dom month_name year] } {
            # Exact match for castable date in format "1st Jan 2014" or "1st Jan"
            return 1

        } elseif { [regexp -nocase -- {^(Jan|January|Feb|February|Mar|March|Apr|April|May|Jun|June|Jul|July|Aug|August|Sep|September|Oct|October|Nov|November|Dec|December)\s+([0-9]+)(?:st|th|nd|rd)?(?:\s+([12]\d{3}))?$} $string -> month_name dom year] } {
            # Exact match for castable date in format "Jan 1st 2014" or "Jan 1st"
            return 1

        }  elseif { [regexp -nocase -- {^(Jan|January|Feb|February|Mar|March|Apr|April|May|Jun|June|Jul|July|Aug|August|Sep|September|Oct|October|Nov|November|Dec|December)(?:\s+([12]\d{3}))?$} $string -> month_name year] } {
            # Exact match in format "Jan 2006" or "Jan"
            return 1

        }  else {
            # could not parse string
            return 0
        }
    }

    proc base64 {string} {
        #| Checks if the given string has only allowable base64 characters and is of the correct format.
        if { [regexp {^[A-Za-z0-9/+\r\n]+=*$} $string] \
                 && ([string length $string]-[regexp -all -- \r?\n $string])*6%8==0 } {
            return 1
        } else {
            return 0
        }
    }

    proc mobile_number {string} {
        #| Checks if the given string is of the form of a UK mobile telephone number.
        regsub -all {[^0-9]} $string {} tel_no
        if {  [regexp {^(07[1-57-9][0-9]{8}|07624[0-9]{6})$} $tel_no] } {
            return 1
        } else {
            return 0
        }
    }

    proc hex {string} {
        #| Checks if the given string is a hex number.
        return [regexp -nocase {^[0-9a-f]*$} $string]
    }

    proc url {args} {
        #| Checks if the given string is a URL.
        #| This is a more restrictive subset of all legal uri's defined by RFC 3986
        #| Relax as needed
        qc::args $args -relative -- url
        qc::default relative false
        if { $relative } {
            return [regexp -expanded {
                # path
                ^([a-zA-Z0-9_\-\.~+/%&]+)?
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
                ([a-zA-Z0-9_\-\.~+/%&]+)?
                # query
                (\?[a-zA-Z0-9_\-\.~+/%=&]+)?
                # anchor
                (\#[a-zA-Z0-9_\-\.~+/%]+)?
                $
            } $url]
        }
    }

    proc url_path {string} {
	#| Checks if the given string is an url path.
	return [regexp {/([a-zA-Z0-9\-._~]|%[0-9a-fA-F]{2}|[!$&'()*+,;=:@]|/)*$} $string]
    }

    proc ipv4 {string} {
        #| Checks if the given string follows the IPv4 format.
        # TODO checks structure only, will allow 9999.9999.9999.9999
        if { [regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$} $string] } {
            return 1
        } else {
            return 0
        }
    }

    proc cidrnetv4 {string} {
        #| Checks if the given string follows the CIDR NETv4 format.
        if { [regexp {^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$} $string] } {
            return 1
        } else {
            return 0
        }
    }

    proc uri {uri} {
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

        set absolute_uri_re [subst -nocommands -nobackslashes {
            ^
            (?:
             ${scheme}:
             (?:(?://${authority}${path_abempty})|${path_absolute}|${path_rootless}|${path_empty})
             (?:\?${query_char}*)?
             (?:\#${fragment_char}*)?
             )
            $
        }]
        
        set relative_uri_re1 [subst -nocommands -nobackslashes {
            ^
            (?:
             ${path_absolute}
             (?:\?${query_char}*)?
             (\#${fragment_char}*)?
             )
            $
        }]

        set relative_uri_re2 [subst -nocommands -nobackslashes {
            ^
            (?:
             ${path_noscheme}
             (?:\?${query_char}*)?
             (\#${fragment_char}*)?
             )
            $
        }]

        set relative_uri_re3 [subst -nocommands -nobackslashes {
            ^
            (?:
             ${path_empty}
             (?:\?${query_char}*)?
             (\#${fragment_char}*)?
             )
            $
        }]

        set relative_uri_re4 [subst -nocommands -nobackslashes {
            ^
            (?:
             //${authority}${path_abempty}
             (?:\?${query_char}*)?
             (\#${fragment_char}*)?
             )
            $
        }]      

        if {
            [regexp -expanded $absolute_uri_re $uri] 
            || [regexp -expanded $relative_uri_re1 $uri] 
            || [regexp -expanded $relative_uri_re2 $uri]
            || [regexp -expanded $relative_uri_re3 $uri]
            || [regexp -expanded $relative_uri_re4 $uri] 
        } {
            return 1
        } else {
            return 0
        }
    }

    proc interval {text} {
        #| Checks if given text is an interval
        # (more restrictive than postgres, relax as needed)
        return \
            [regexp \
                 {((^| +)(\+|-)?[0-9]+ +(year|month|week|day|hour|minute|second)s?)+$} \
                 [string tolower $text]]
    }
}

