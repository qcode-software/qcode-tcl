package provide qcode 2.0
package require doc
namespace eval qc {
    namespace export cast_*
}

doc cast {
    Title "Casting Procs"
    Url {/qc/wiki/CastPage}
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
    regexp {^0+([0-9]+)$} $string -> string
    # Convert decimals
    if { [string first . $string]!=-1 } {
	set string [qc::round $string 0]
    }
    if { [string is integer -strict $string] } {
	return $string
    } else {
	error "Could not cast $original to integer" {} CAST
    }
}

doc qc::cast_integer {
    Parent cast
    Examples {
	% cast_integer 2,305
	% 2305
	% 
	% cast_integer 2.366%
	% 2
	%
	% cast_integer 43e2
	4300
    }
}

proc qc::cast_int {string} {
    return [qc::cast_integer $string]
}

proc qc::cast_decimal {string {precision ""}} {
    #| Try to cast given string into a decimal value
    set original $string
    set string [string map {, {} % {}} $string]
    if { [string is double -strict $string] } {
	if { [string is integer -strict $precision] } {
	    return [qc::round $string $precision]
	} else {
	    return $string
	}
    } else {
	error "Could not cast $original to decimal" {} CAST
    }
}

doc qc::cast_decimal {
    Parent cast
    Examples {
	% cast_decimal 2,305.25
	% 2305.25
	% 
	% cast_decimal 2.366%
	% 2.366
	%
	% cast_decimal 3.689 2
	3.69
    }
}

proc qc::cast_date {string} {
    #| Try to convert the given string into an ISO date.
    return [clock format [cast_epoch $string] -format "%Y-%m-%d"]
}

doc qc::cast_date {
    Parent cast
    Examples {
	% cast_date 12/5/07
	2007-05-12
	# At present dates in this format are assumed to be European DD/MM/YY
	%
	% cast_date yesterday
	2007-05-11
	%
	% cast_date "June 23rd"
	2007-06-23
	%
	% cast_date 16
	% 2007-10-16
	%
	% cast_date "23rd 2008 June"
	2008-06-23
    }
}

proc qc::cast_timestamp {string} {
    #| Try to convert the given string into an ISO datetime.
    return [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M:%S"]
}

doc qc::cast_timestamp {
    Parent cast
    Examples {
        % qc::cast_timestamp today
        2012-08-16 17:04:47
        % qc::cast_timestamp 12/5/12
        2012-05-12 00:00:00
        % qc::cast_timestamp 12:33:33 
        2012-08-12 12:33:33
    }
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
    if { [string is integer -strict $string] && $string>31 } {
	return $string
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

doc qc::cast_epoch {
    Parent cast    
    Examples {
	% cast_epoch 12/5/07
	1178924400
	# At present dates in this format are assumed to be European DD/MM/YY
	%
	% cast_epoch yesterday
	1192569505
	%
	% cast_epoch 2007-10-16
	1192489200
	% 
	# times can be hh:mm or hh:mm:ss
	% cast_epoch "2007-10-16 10:12:36"
	1192525956
        # With ISO offset timezone in formats -hh, -hhmm or -hh:mm
        % cast_epoch "2007-10-16 12:14:34.15445 +05"
        1192518874
    }
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

doc qc::cast_boolean {
    Parent cast    
    Examples {
	% cast_boolean YES
	t
	%
	% cast_boolean 0
	f
	%
	% cast_boolean true Y N
	Y
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

doc qc::cast_postcode {
    Parent cast    
    Examples {
	% cast_postcode AB12CD
	AB1 2CD
	%
	% cast_postcode AB123CD
	AB12 3CD
	%
	# Yzero should be YO
	% cast_postcode Y023 3CD
	YO23 3CD

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

doc qc::cast_creditcard {
    Examples {
	% cast_creditcard "4111 1111 1111 1111"
	4111111111111111
	%
	% cast_creditcard "4213 3222 1121 1112"
	4213322211211112 is not a valid credit card number
    }
}
