namespace eval qc {
    namespace export cast_* data_type_error_check
}

proc qc::cast_integer {string} {
    #| Deprecated - see qc::cast integer
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
    #| Deprecated - see qc::cast integer
    return [qc::cast_integer $string]
}

proc qc::cast_decimal {string {precision ""}} {
    #| Deprecated - see qc::cast decimal
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

proc qc::cast_date {string} {
    #| Try to convert the given string into an ISO date.
    return [clock format [cast_epoch $string] -format "%Y-%m-%d"]
}

proc qc::cast_timestamp {string} {
    #| Deprecated - see qc::cast timestamp
    #| Try to convert the given string into an ISO datetime.
    return [clock format [cast_epoch $string] -format "%Y-%m-%d %H:%M:%S"]
}

proc qc::cast_timestamptz {string} {
    #| Deprecated - see qc::cast timestamptz
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
    #| Deprecated - see qc::cast boolean
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
    #| Deprecated - see qc::cast boolean
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

proc qc::cast_values2model {args} {
    #| Check the data types of the values against the definitions for these names.
    #| Returns a new list of values after casting to appropriate type.
    #| Throws an error if type-checking fails.
    if { [llength $args]%2 != 0 } {
        return -code error "usage cast_values2model name value ?name value?"
    }
    set casted_dict {}
    set errors {}
    
    dict for {name value} $args {
        set table ""
        # Check if name is fully qualified
        if {![regexp {^([^\.]+)\.([^\.]+)$} $name -> table column] } {
            lassign [qc::db_qualified_table_column $name] table column
        }
        
        set data_type [qc::db_column_type $table $column]
        set nullable [qc::db_column_nullable $table $column]

        # Check if nullable
        if {! $nullable && $value eq ""} {
            lappend errors "$column cannot be empty."
            continue
        } elseif {$nullable && $value eq ""} {
            lappend casted_dict $name $value
            continue
        }

        # Check value against data type
        if {[qc::castable $data_type $value]} {
            lappend casted_dict $name [qc::cast $data_type $value]
        } else {           
            lappend errors [qc::html_escape [qc::data_type_error_check $data_type $value]]
        }

        # Check constraints
        set results [qc::db_eval_column_constraints $table $column $args]
        if { [llength $results]>0 && ! [expr [join [dict values $results] " && "]] } {
            set failed_constraints {}
            dict for {constraint passed} $results {
                if {!$passed} {
                    lappend failed_constraints $constraint
                }
            }
            set error_message [qc::html_escape "Value \"$value\" for column \"$column\" failed the following constraint(s) [join $failed_constraints ", "]"]
            lappend errors $error_message
        }
    }
    
    if {[llength $errors] > 0} {
        return -code error -errorcode USER [qc::html_list $errors]
    } else {
        return $casted_dict
    }
}

proc qc::data_type_error_check {data_type value} {
    #| Checks the given value against the data type and reports any error.
    switch -regexp -matchvar matches -- $data_type {
        {^varchar(\(([0-9]+)\))?$} {
            set length [string range [lindex $matches 1] 1 [expr {[string length [lindex $matches 1]] - 2}]]              
            if {! [qc::is varchar $length $value]} {
                return "\"[qc::trunc $value 100]...\" is too long. Must be $length characters or less."
            }
        }
        {^char(\(([0-9]+)\))?$} {
            set length [string range [lindex $matches 1] 1 [expr {[string length [lindex $matches 1]] - 2}]]
            set chars "characters"
            if {$length eq ""} {
                set length 1
                set chars "character"
            }
            if {! [qc::is char $length $value]} {
                if {[string length $value] < $length} {
                    return "\"$value\" is too short. Must be exactly $length $chars."
                } elseif {[string length $value] > $length} {
                    return "\"[qc::trunc $value 100]...\" is too long. Must be exactly $length $chars."
                }
            }
        }
        ^int4$ {
            if {! [qc::is integer $value] && ! [qc::castable integer $value]} {
                return "\"$value\" is not a valid integer. It must be a number between -2147483648 and 2147483647."
            }
        }
        ^int8$ {
            if {! [qc::is bigint $value] && ! [qc::castable bigint $value]} {
                return "\"$value\"is not a valid big int. It must be a number between -9223372036854775808 and 9223372036854775807."
            } 
        }
        ^int2$ {
            if {! [qc::is smallint $value] && ![qc::castable smallint $value]} {
                return "\"$value\"is not a valid small int. It must be a number between -32768 and 32767."
            }  
        }
        ^bool$ {
            if {! [qc::is boolean $value] && ! [qc::castable boolean $value]} {
                return "\"$value\"is not a valid boolean value."
            }
        }
        ^timestamp$ {
            if {! [qc::is timestamp $value] && ! [qc::castable timestamp $value]} {
                return "\"$value\"is not a valid timestamp."
            }
            
        }
        ^timestamptz$ {
            if {! [qc::is timestamptz $value] && ! [qc::castable timestamptz $value]} {
                return "\"$value\"is not a valid timestamptz."
            }           
        }
        {^(numeric|decimal)$} {
            if {! [qc::is decimal $value] && ! [qc::castable decimal $value]} {
                return "\"$value\"is not a valid decimal."
            }
        }
        ^text$ {
            return
        }
        ^safe_html$ {
            if {! [qc::is safe_html $value]} {
                return "\"[qc::trunc $value 50]...\" contains invalid or unsafe HTML."
            }
        }
        ^safe_markdown$ {
            if {! [qc::is safe_markdown $value]} {
                return "\"[qc::trunc $value 50]...\" contains invalid or unsafe HTML."
            }
        }
        default {
            # might be an enumeration or domain
            if {[qc::db_enum_exists $data_type]} {
                if {! [qc::castable enumeration $data_type $value]} {
                    return "\"$value\" is not a valid value for enum \"$data_type\"."
                }
            } elseif {[qc::db_domain_exists $data_type]} {
                set base_type [qc::db_domain_base_type $data_type]
                lassign [qc::db_domain_constraint $data_type] constraint_name check_clause
                set is_base_type [qc::is $base_type $value]
                set constraint_met [qc::db_eval_domain_constraint $data_type $value]
                if {! $is_base_type && ! $constraint_met} {
                    return "[data_type_error_check $base_type $value] and failed to meet the constraint $constraint_name."
                } elseif {! $is_base_type} {
                    return [qc::data_type_error_check $base_type $value]
                } elseif {! $constraint_met} {
                    return "\"[qc::trunc $value 100]...\" failed to meet the constraint $constraint_name."
                }
            } else {
                return -code error "Unrecognised data type \"$data_type\""
            }
        }
    }
    return
}


namespace eval qc::cast {
    
    namespace export integer bigint smallint decimal boolean timestamp timestamptz char varchar text enumeration domain safe_html safe_markdown
    namespace ensemble create -unknown {
        data_type_parser
    }

    proc integer {string} {
        #| Try to cast given string into an integer
        set result [integer_convert $string]
        if { [qc::is integer $result] } {
            return $result
        } else {
            return -code error -errorcode CAST "Could not cast $string to integer."
        }
    }

    proc bigint {string} {
        #| Try to cast the given string into an integer checking if it falls into big int range.
        set result [integer_convert $string]
        if { [qc::is bigint $result] } {
            return $result
        } else {
            return -code error -errorcode CAST "Could not cast $string to bigint."
        }
    }

    proc smallint {string} {
        #| Try to cast the given string into an integer checking if it falls into small int range.
        set result [integer_convert $string]
        if { [qc::is smallint $result] } {
            return $result
        } else {
            return -code error -errorcode CAST "Could not cast $string to smallint."
        }
    }

    proc integer_convert {string} {
        #| Tries to form an integer from the given string.
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
        return $string
    }

    proc decimal {string {precision ""}} {
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
            return -code error -errorcode CAST "Could not cast $original to decimal."
        }
    }

    proc boolean { string {true t} {false f} } {
        #| Cast a string as a boolean.
        if { [string toupper $string] in {Y YES TRUE T 1} } {
            return $true
        } elseif {[string toupper $string] in {N NO FALSE F 0} } {
            return $false
        } else {
            return -code error -errorcode CAST "Can't cast \"$string\" to boolean data type."
        }
    }

    proc timestamp {string} {
        #| Try to convert the given string into an ISO datetime.
        return [clock format [qc::cast_epoch $string] -format "%Y-%m-%d %H:%M:%S"]
    }

    proc timestamptz {string} {
        #| Try to convert the given string into an ISO datetime with timezone.
        return [clock format [qc::cast_epoch $string] -format "%Y-%m-%d %H:%M:%S %z"]
    }

    proc char {length string} {
        #| Cast to char.
        if { [string length $string] == $length } {
            return $string
        } else {
            return -code error -errorcode CAST "Can't cast \"$string\" to char($length) data type."
        }
    }

    proc varchar {length string} {
        #| Cast to varchar.
        if { [string length $string] <= $length } {
            return $string
        } else {
            return -code error -errorcode CAST "Can't cast \"$string\" to varchar($length). String is too long."
        }
    }

    proc text {string} {
        #| Cast to text.
        return $string
    }
    
    proc enumeration {name value} {
        #| Cast $value to enumeration of $name.
        set value [string toupper $value]
        if {$value in [qc::db_enum_values $name]} {
            return $value
        } else {
            return -code error -errorcode CAST "Can't cast \"$value\": not a valid value for enumeration \"$name\"."
        }
    }

    proc domain {domain_name value} {
        #| Cast value to the domain $domain_name.
        set base_type [qc::db_domain_base_type $domain_name]
        if { ![qc::is $base_type $value] } {
            return -code error -errorcode CAST "Can't cast \"[qc::trunc $value 100]...\": not a valid value for base type \"$base_type\" while checking \"$domain_name\" type."
        } elseif { [qc::is $domain_name $value] } {
            return $value
        } else {
            return -code error -errorcode CAST "Can't cast \"[qc::trunc $value 0 100]...\": not a valid value for \"$domain_name\"."
        }
    }

    proc safe_html {text} {
        #| Cast text to safe html.
        set safe_html [qc::html_sanitize $text]
        if {! [regexp {^<root>(.+)</root>$} $text]} {
            # Wrap the text with a root node so that it can be stored in the database as XML.
            set safe_html [qc::h root $safe_html]
        }
        set doc [dom parse -html $safe_html]
        set xml [$doc asXML -escapeNonASCII]
        $doc delete
        return $xml
    }

    proc safe_markdown {text} {
        #| Cast text to safe markdown.
        if {[qc::is safe_markdown $text]} {
            return $text
        } else {
            return -code error -errorcode CAST "Can't cast \"[qc::trunc $text 100]...\": not safe markdown."
        }
    }
}