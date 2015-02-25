namespace eval qc {
    namespace export cast_*
}

proc qc::cast_integer {string} {
    #| Try to cast given string into an integer
    set original $string
    # Convert e notation
    if { [string first e $string]!=-1 || [string first E $string]!=-1 } {
	set string [exp2string $string]
    }
    set string [string map {, {} % {}} $string]
    # Strip leading zeros if followed by digit
    # This copes with 0 and 00
    regsub {^(-?)0+([0-9]+)$} $string {\1\2} string
    # Convert decimals
    if { [string first . $string]!=-1 } {
	set string [qc::round $string 0]
    }
    if { [qc::is_integer $string] } {
	return $string
    } else {
	error "Could not cast $original to integer" {} CAST
    }
}

proc qc::cast_int {string} {
    return [qc::cast_integer $string]
}

proc qc::cast_decimal {string {precision ""}} {
    #| Deprecated - see qc::cast decimal
    #| Try to cast given string into a decimal value
    if { $precision ne "" } {
        set p [string length $string]
        if { $precision >= $p } {
            set p [expr {$p + $precision}]
        }
        return [qc::cast decimal -precision $p -scale $precision $string]
    } else {
        return [qc::cast decimal $string]
    }
}

proc qc::cast_date {string} {
    #| Try to convert the given string into an ISO date.
    return [clock format [cast_epoch $string] -format "%Y-%m-%d"]
}

proc qc::cast_timestamp {string} {
    #| Try to convert the given string into an ISO datetime.
    return [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M:%S"]
}

proc qc::cast_timestamptz {string} {
    #| Try to convert the given string into an ISO datetime with timezone.
    return [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M:%S %z"]
}

proc qc::cast_epoch { string } {
    #| Try to convert the given string into an epoch
    #
    set string [string map [list "&#8209;" -] $string]
    #### EXACT MATCHES ####
    if { [string equal $string ""] } {
	error "Can't cast an empty string to epoch"
    }
    # Looks like a number but really an iso date without delimitor.
    if { [regexp {^(19\d\d|20\d\d)(\d\d)(\d\d)$} $string -> year month day] } {
	return [clock scan "$year-$month-$day"]
    }
    # Already an epoch
    if { [string is wideinteger -strict $string] } {
        if { $string > [clock scan "5000-01-01"] } {
            # Interpret as milliseconds past epoch
            return [expr {${string}/1000}]
        } elseif { $string>31 } {
            return $string
        }
    }
    # Exact ISO date
    if { [regexp {^(\d{4}|\d{2}|\d)-(\d{1,2})-(\d{1,2})$} $string -> year month day] } {
	 return [clock scan "$year-$month-$day"]
    }
    # Exact ISO datetime
    if { [regexp {^(\d{4}|\d{2}|\d)-(\d{1,2})-(\d{1,2})( |T)(\d{1,2}:\d{1,2}(:\d{1,2})?)$} $string -> year month day . time] } {
	return [clock scan "$year-$month-$day $time"]
    }
    # Exact ISO datetime with offset timezone e.g. "2012-08-13 10:21:23.7777 -06:00"
    # Accepts offsets in formats -hh, -hhmm, or -hh:mm
    if { [regexp {^(\d{4}|\d{2}|\d)-(\d{1,2})-(\d{1,2})(?: |T)(\d{1,2}:\d{1,2})(?::(\d{1,2})(?:\.\d+)?)?\s?(Z|[-+]\d\d(:?\d\d)?)$} $string -> year month day time sec timezone] } {
        if { $timezone eq "Z" } {
            set timezone "+00"
        }
        if { $sec ne "" } {
            set time "$time:$sec"
        }
	return [clock scan "$year-$month-$day $time" -timezone "$timezone"]
    }
    # rfc-822 style dates used in emails.
    # "Fri, 17 Aug 2012 12:51:36 +0100"
    if { [regexp {(\d{1,2}) +(Jan|January|Feb|February|Mar|March|Apr|April|May|Jun|June|Jul|July|Aug|August|Sep|September|Oct|October|Nov|November|Dec|December) +(\d{4}) +(\d{1,2}:\d{1,2})(?::(\d{1,2})(?:\.\d+)?)?\s?(Z|[-+]\d\d(:?\d\d)?)} $string -> day mon year time sec timezone] } {
        if { $timezone eq "Z" } {
            set timezone "+00"
        }
        if { $sec ne "" } {
            set time "$time:$sec"
        }
        set month [expr {[lsearch {January February March April May June July August September October November December} "${mon}*"]+1}]
	return [clock scan "$year-$month-$day $time" -timezone "$timezone"]
    }
    # ISO datetime Don't match the end of line for e.g. "2009-04-06 12:25:18.343"
    if { [regexp {^(19\d\d|20\d\d)(\d\d)(\d\d)( |T)(\d{1,2}:\d{1,2}(:\d{1,2})?)} $string -> year month day . time] } {
	return [clock scan "$year-$month-$day $time"]
    }
    # dd/mm/yyYY
    if { [regexp {^(\d{1,2})[/\.](\d{1,2})[/\.](\d{4}|\d{2}|\d)$} $string -> day month year] } {
	# Assume UK locale dd/mm/yy or dd.mm.yy
	return [clock scan "$year-$month-$day"]
    }
    #### RELATIVE ####
    if { [regexp -nocase -- {(\+-)? ?(this|last|next|[0-9]+) ?(year|month|week|day|hour|minute)s?( ago)?} $string] \
	     || [regexp -nocase -- {(this|last|next) (Mon|Monday|Tue|Tuesday|Wed|Wednesday|Thu|Thurs|Thursday|Fri|Friday|Sat|Saturday|Sun|Sunday)} $string] \
	     || [regexp -nocase -- {today|yesterday|tomorrow} $string] } {
	return [clock scan $string]
    }
    #### RELAXED ####
    # Look for time hh:mm or hh:mm:ss
    if { ![regexp {(^|\W)(\d{1,2}:\d{1,2}(:\d{1,2})?)(\W|$)} $string -> ~ time ~] } { set time "" }
    # ISO format
    if { [regexp {(^|[^0-9])(\d{4}|\d{2}|\d)-(\d{1,2})-(\d{1,2})([^0-9]|$)} $string -> start year month day end] } {
	 return [clock scan "$year-$month-$day $time"]
    }
    if { [regexp {(^|[^0-9])(\d{1,2})[/\.](\d{1,2})[/\.](\d{4}|\d{2}|\d)([^0-9]|$)} $string -> start day month year end] } {
	# Assume UK locale dd/mm/yy or dd.mm.yy
	return [clock scan "$year-$month-$day $time"]
    }
    # dd/mm or dd.mm
    if { [regexp {(^|\W)(\d{1,2})[/\.](\d{1,2})(\W|$)} $string -> start day month end] } {
	set year [clock format [clock seconds] -format "%Y"]
	return [clock scan "$year-$month-$day $time"]
    }
    if { [regexp {(^|[^0-9])(\d{4})([^0-9]|$)} $string -> start year end] } {
	#### Matched YEAR ####
	# year && month && dom
	# 23 June 2006 or June 23rd 2006
	if { [regexp -nocase -- {(^|[^a-zA-Z])(Jan|January|Feb|February|Mar|March|Apr|April|May|Jun|June|Jul|July|Aug|August|Sep|September|Oct|October|Nov|November|Dec|December)([^a-zA-Z]|$)} $string -> start month_name end] \
	     && [regexp -nocase -- {(^|\W)(\d{1,2})(st|nd|rd|th)?(\W|$)} $string -> start dom suffix end] } {
	    # month and dom
	    return [clock scan "$dom $month_name $year $time"]
	}
    } else {
	#### NO YEAR ####
	# no year && month && dom
	# 23rd June or Sept 11th
	if { [regexp -nocase -- {(^|[^a-zA-Z])(Jan|January|Feb|February|Mar|March|Apr|April|May|Jun|June|Jul|July|Aug|August|Sep|September|Oct|October|Nov|November|Dec|December)([^a-zA-Z]|$)} $string -> start month_name end] \
		 && [regexp -nocase -- {(^|\W)(\d{1,2})(st|nd|rd|th)(\W|$)} $string -> start dom suffix end] } {	 
	    set year [clock format [clock seconds] -format "%Y"]
	    return [clock scan "$dom $month_name $year $time"]
	}
	# dd or dd+suffix eg 23rd or 2nd ONLY 
	if { [regexp -nocase -- {(^|\W)(\d{1,2})(st|nd|rd|th)?(\W|$)} $string -> start day suffix end] } {
	    set year [clock format [clock seconds] -format "%Y"]
	    set month [clock format [clock seconds] -format "%m"]
	    return [clock scan "$year-$month-$day $time"]
	}	
	if { [regexp -nocase -- {(^|\W)(Mon|Monday|Tue|Tuesday|Wed|Wednesday|Thu|Thurs|Thursday|Fri|Friday|Sat|Saturday|Sun|Sunday)(\W|$)} $string -> start dow end] } {
	    return [clock scan "$dow $time"]
	}
    }
    # try TCL
    return [clock scan $string]
}

proc qc::cast_boolean { string {true t} {false f} } {
    #| Cast a string as a boolean
    # strip html
    # TODO Aolserver only
    set string [qc::strip_html $string]
    if { [in {Y YES TRUE T 1} [upper $string]] } {
	return $true
    } elseif { [in {N NO FALSE F 0} [upper $string]] } {
	return $false
    } else {
	error "Can't cast \"$string\" to boolean data type"
    }
}

proc qc::cast_bool { string {true t} {false f} } {
    return [qc::cast_boolean $string $true $false]
}

proc qc::cast_postcode { postcode } {
    #| Try to cast a string into UK Postcode form
    set saved $postcode
    set postcode [string toupper $postcode]
    # BFPO 
    if { [eq [string range $postcode 0 3] BFPO] } {
	return $postcode
    }
    # convert AB12CD -> AB1 2CD or AB123CD -> AB12 3CD
    if { [string first " " $postcode] == -1 } {
	set cut [expr {[string length $postcode]-3-1}]
	set postcode "[string range $postcode 0 $cut] [string range $postcode [expr {$cut+1}] end]"
    }
    if { [is_postcode $postcode] } {
	return $postcode
    }
    # Convert zero -> CAPITAL O e.g. "Y023 3CD" -> "YO23 3CD"
    regsub {^([A-Z])0([0-9]{1,2}) (.+)$} $postcode {\1O\2 \3} postcode

    if { [is_postcode $postcode] } {
	return $postcode
    } else {
	error "Could not cast $saved to Postcode."
    }
}

proc qc::cast_creditcard { no } {
    regsub -all {[^0-9]} $no "" no
    if { [is_creditcard $no] } {
	return $no
    } else {
	error "$no is not a valid credit card number"
    }
}

proc qc::cast_period {string} {
    #| Return a pair of dates defining the period.
    set month_names [list Jan January Feb February Mar March Apr April May Jun June Jul July Aug August Sep September Oct October Nov November Dec December]
    set regexp_map [list \$month_names_regexp [join $month_names |]]

    if { [regexp -nocase {^\s*(.*?)\s+to\s+(.*?)\s*$} $string -> period1 period2] } {
        # Period defined by two periods eg "Jan 2011 to March 2011"
        lassign [qc::cast_period $period1] from_date .
        lassign [qc::cast_period $period2] . to_date

    } elseif { [qc::is_date $string] } {
        # String is an iso date eg "2014-01-01"
        set from_date $string
        set to_date $from_date

    } elseif { [regexp {^([12]\d{3})$} $string -> year] } {
        # Exact match for year eg "2006"
        set from_date [date_year_start $year-01-01]
        set to_date [date_year_end $year-01-01]

    } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)\s+([12]\d{3})$}] $string -> month_name year] } {
        # Exact match in format "Jan 2006"
        set epoch [clock scan "01 $month_name $year"]
        set from_date [date_month_start $epoch]
        set to_date [date_month_end $epoch]

    } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)$}] $string -> month_name] } {
        # Exact match in format "Jan" (assume current year)
        set epoch [clock scan "01 $month_name [date_year now]"]
        set from_date [date_month_start $epoch]
        set to_date [date_month_end $epoch]

    } elseif { [regexp -nocase -- [string map $regexp_map {^([0-9]{1,2})(?:st|th|nd|rd)?\s+($month_names_regexp)\s+([12]\d{3})$}] $string -> dom month_name year] } {
        # Exact match for castable date in format "1st Jan 2014"
        set epoch [clock scan "$dom $month_name $year"]
        set from_date [cast_date $epoch]
        set to_date $from_date

    } elseif { [regexp -nocase -- [string map $regexp_map {^([0-9]{1,2})(?:st|th|nd|rd)?\s+($month_names_regexp)$}] $string -> dom month_name] } {
        # Exact match for castable date in format "1st Jan" (assume current year)
        set epoch [clock scan "$dom $month_name [date_year now]"]
        set from_date [cast_date $epoch]
        set to_date $from_date

    } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)\s+([0-9]{1,2})(?:st|th|nd|rd)?\s+([12]\d{3})$}] $string -> month_name dom year] } {
        # Exact match for castable date in format "Jan 1st 2014"
        set epoch [clock scan "$dom $month_name $year"]
        set from_date [cast_date $epoch]
        set to_date $from_date

    } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)\s+([0-9]{1,2})(?:st|th|nd|rd)?$}] $string -> month_name dom] } {
        # Exact match for castable date in format "Jan 1st" (assume current year)
        set epoch [clock scan "$dom $month_name [date_year now]"]
        set from_date [cast_date $epoch]
        set to_date $from_date

    } else {
        # error - could not parse string
        error "Could not parse string \"$string\" into dates that define a period."
    }
    
    return [list $from_date $to_date]
}

proc qc::is_period {string} {
    #| Test if string can be casted to a pair of dates defining a period.
    set month_names [list Jan January Feb February Mar March Apr April May Jun June Jul July Aug August Sep September Oct October Nov November Dec December]
    set regexp_map [list \$month_names_regexp [join $month_names |]]

    if { [regexp -nocase {^\s*(.*?)\s+to\s+(.*?)\s*$} $string -> period1 period2] } {
        # Period defined by two periods eg "Jan 2011 to March 2011"
        if { [qc::is_period $period1] && [qc::is_period $period2] } {
            return true
        } else {
            return false
        }

    } elseif { [qc::is_date $string] } {
        # String is an iso date eg "2014-01-01"
        return true

    } elseif { [regexp {^([12]\d{3})$} $string -> year] } {
        # Exact match for year eg "2006"
        return true

    } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)\s+([12]\d{3})$}] $string -> month_name year] } {
        # Exact match in format "Jan 2006"
        return true

    } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)$}] $string -> month_name] } {
        # Exact match in format "Jan" (assume current year)
        return true

    } elseif { [regexp -nocase -- [string map $regexp_map {^([0-9]{1,2})(?:st|th|nd|rd)?\s+($month_names_regexp)\s+([12]\d{3})$}] $string -> dom month_name year] } {
        # Exact match for castable date in format "1st Jan 2014"
        return true

    } elseif { [regexp -nocase -- [string map $regexp_map {^([0-9]{1,2})(?:st|th|nd|rd)?\s+($month_names_regexp)$}] $string -> dom month_name] } {
        # Exact match for castable date in format "1st Jan" (assume current year)
        return true       

    } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)\s+([0-9]{1,2})(?:st|th|nd|rd)?\s+([12]\d{3})$}] $string -> month_name dom year] } {
        # Exact match for castable date in format "Jan 1st 2014"
        return true

    } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)\s+([0-9]{1,2})(?:st|th|nd|rd)?$}] $string -> month_name dom] } {
        # Exact match for castable date in format "Jan 1st" (assume current year)
        return true

    } else {
        # could not parse string
        return false
    }

    if { [regexp -nocase {^\s*(.*?)\s+to\s+(.*?)\s*$} $string -> period1 period2] } {
        # Period defined by two periods eg "Jan 2011 to March 2011"
        if { [qc::is_period $period1] && [qc::is_period $period2] } {
            return true
        } else {
            return false
        }

    } elseif { [qc::is_date $string] } {
        # String is an iso date eg "2014-01-01"
        return true

    } elseif { [regexp {^([12]\d{3})$} $string -> year] } {
        # Exact match for year eg "2006"
        return true

    } elseif { [regexp -nocase -- {^([0-9]+)(?:st|th|nd|rd)?\s+(Jan|January|Feb|February|Mar|March|Apr|April|May|Jun|June|Jul|July|Aug|August|Sep|September|Oct|October|Nov|November|Dec|December)(?:\s+([12]\d{3}))?$} $string -> dom month_name year] } {
        # Exact match for castable date in format "1st Jan 2014" or "1st Jan"
        return true

    } elseif { [regexp -nocase -- {^(Jan|January|Feb|February|Mar|March|Apr|April|May|Jun|June|Jul|July|Aug|August|Sep|September|Oct|October|Nov|November|Dec|December)\s+([0-9]+)(?:st|th|nd|rd)?(?:\s+([12]\d{3}))?$} $string -> month_name dom year] } {
        # Exact match for castable date in format "Jan 1st 2014" or "Jan 1st"
        return true

    }  elseif { [regexp -nocase -- {^(Jan|January|Feb|February|Mar|March|Apr|April|May|Jun|June|Jul|July|Aug|August|Sep|September|Oct|October|Nov|November|Dec|December)(?:\s+([12]\d{3}))?$} $string -> month_name year] } {
        # Exact match in format "Jan 2006" or "Jan"
        return true

    }  else {
        # could not parse string
        return false
    }
}

namespace eval qc::cast {
    namespace export decimal
    namespace ensemble create 

    proc decimal {args} {
        #| Try to cast given string into a decimal value with the given precision and/or scale if present.
        qc::args $args -precision ? -scale ? -- string
        set original $string
        set string [string map {, {} % {}} $string]
        if { [string is double -strict $string] } {
            if { ! [info exists scale] && ! [info exists precision] } {
                # Scale and precision not given.
                return [qc::exp2string $string]
            } elseif { [info exists scale] && ! [info exists precision] } {
                # Scale given but not precision.
                return -code error -errorcode CAST "Precision must be provided with scale."
            } elseif { [info exists precision] } {
                # Precision given.
                if { $precision <= 0 || ! [qc::is integer $precision] } {
                    return -code error -errorcode CAST "Precision must be a positive integer."
                }

                if { ! [info exists scale] } {
                    # Scale wasn't given so set it to 0.
                    set scale 0
                }

                if { $scale < 0 || ! [qc::is integer $scale]} {
                    return -code error "Scale must be a non-negative integer."
                }
                
                # Expand the number and round it to the scale and check the result.
                set rounded [qc::round [qc::exp2string $string] $scale]
                set parts [split $rounded .]
                set left_count [string length [lindex $parts 0]]
                set right_count [string length [lindex $parts 1]]
                if { $left_count == 0 } {
                    # The leading zero wasn't given.
                    return -code error -errorcode CAST "Incomplete numeric string."
                }
                
                set left_digit_max [expr {$precision - $scale}]
                if { $left_count > $left_digit_max || $right_count > $scale} {
                    return -code error -errorcode CAST "The resulting number ($rounded) is too large for the given precision ($precision) and scale ($scale)."
                } else {
                    return $rounded
                }
            }
        } else {
            return -code error -errorcode CAST "Could not cast $original to decimal."
        }
    }
}