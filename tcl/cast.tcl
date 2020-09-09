namespace eval qc {
    namespace export cast_* data_type_error_check
}

proc qc::cast_integer {string} {
    #| Deprecated - see qc::cast integer
    #| Try to cast given string into an integer
    return [qc::cast integer $string]
}

proc qc::cast_int {string} {
    #| Deprecated - see qc::cast integer
    return [qc::cast integer $string]
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
    #| Deprecated - see qc::cast date
    #| Try to convert the given string into an ISO date.
    return [qc::cast date $string]
}

proc qc::cast_timestamp {string} {
    #| Deprecated - see qc::cast timestamp
    #| Try to convert the given string into an ISO datetime.
    return [qc::cast timestamp $string]
}

proc qc::cast_timestamptz {string} {
    #| Deprecated - see qc::cast timestamptz
    #| Try to convert the given string into an ISO datetime with timezone.
    return [qc::cast timestamptz $string]
}

proc qc::cast_epoch { string } {
    #| Deprecated - see qc::cast epoch
    #| Try to convert the given string into an epoch
    return [qc::cast epoch $string]
}

proc qc::cast_boolean { string {true t} {false f} } {
    #| Deprecated - see qc::cast boolean
    #| Cast a string as a boolean
    return [qc::cast boolean $string $true $false]
}

proc qc::cast_bool { string {true t} {false f} } {
    #| Deprecated - see qc::cast boolean
    return [qc::cast boolean $string $true $false]
}

proc qc::cast_postcode { postcode } {
    #| Deprecated - see qc::cast postcode
    #| Try to cast a string into UK Postcode form
    return [qc::cast postcode $postcode]
}

proc qc::cast_creditcard { no } {
    #| Deprecated - see qc::cast creditcard
    return [qc::cast creditcard $no]
}

proc qc::cast_period {string} {
    #| Deprecated - see qc::cast period
    #| Return a pair of dates defining the period.
    return [qc::cast period $string]
}

proc qc::cast_url {string} {
    #| Deprecated - see qc::cast url
    #| (See also qc::is url)
    return [qc::cast url $string]
}

proc qc::cast_relative_url {string} {
    #| Deprecated - see qc::cast url
    #| (See also qc::is url)
    return [qc::cast relative_url $string]
}

proc qc::is_period {string} {
    #| Deprecated - see qc::is period
    #| Test if string can be casted to a pair of dates defining a period.
    return [qc::is period $string]
}

proc qc::cast_value2model {name value} {
    #| Return the value cast to the data model.
    #| Name can be a partial or fully qualified column identifier.
    
    # Resolve name to column, table, and schema
    lassign [qc::memoize qc::db_resolve_field_name $name] {*}{
        schema
        table
        column
    }

    set data_type [qc::memoize qc::db_column_type \
                       -qualified -- $schema $table $column]
    set nullable [qc::memoize qc::db_column_nullable $schema $table $column]

    # Check if nullable
    if {! $nullable && $value eq ""} {
        error "$column cannot be empty."
    } elseif {$nullable && $value eq ""} {
        return $value
    }

    # Check value against data type
    if {[qc::castable $data_type $value]} {
        return [qc::cast $data_type $value]
    } else {
        error [qc::data_type_error_check $data_type $value]
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

        # Resolve name to column, table, and schema
        lassign [qc::memoize qc::db_resolve_field_name $name] {*}{
            schema
            table
            column
        }
        
        set data_type [qc::memoize qc::db_column_type \
                           -qualified -- $schema $table $column]
        set nullable [qc::memoize qc::db_column_nullable $schema $table $column]

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
            if {[qc::memoize qc::db_enum_exists $data_type]} {
                if {! [qc::castable enumeration $data_type $value]} {
                    return "\"$value\" is not a valid value for enum \"$data_type\"."
                }
            } elseif {[qc::memoize qc::db_domain_exists $data_type]} {
                set base_type [qc::memoize qc::db_domain_base_type $data_type]
                set constraints [qc::memoize qc::db_domain_constraints $data_type]
                set is_base_type [qc::is $base_type $value]
                set failed_constraints [list]
                dict for {constraint_name check_clause} $constraints {
                    if { ! [qc::db_eval_domain_constraint $value $base_type $check_clause] } {
                        lappend failed_constraints $constraint_name
                    }
                }
                if { ! $is_base_type && [llength $failed_constraints] > 0 } {
                    return "[data_type_error_check $base_type $value] and failed to meet the constraint(s) [join $failed_constraints ", "]"
                } elseif { ! $is_base_type } {
                    return [qc::data_type_error_check $base_type $value]
                } elseif { [llength $failed_constraints] > 0 } {
                    return "\"[qc::trunc $value 100]...\" failed to meet the constraint(s) [join $failed_constraints ", "]"
                }
            } else {
                return -code error "Unrecognised data type \"$data_type\""
            }
        }
    }
    return
}


namespace eval qc::cast {
    
    namespace export integer bigint smallint decimal boolean timestamp timestamptz char varchar text enumeration domain safe_html safe_markdown date postcode creditcard period epoch url url_relative url_path s3_url time interval
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
            set string [qc::exp2string $string]
        }
        set string [string map {, {} % {}} $string]
        # Strip leading zeros if followed by digit
        # This copes with 0 and 00
        regsub {^(-?)0+([0-9]+)$} $string {\1\2} string
        # Convert decimals
        if { [string first . $string]!=-1 } {
            set string [qc::round $string 0]
        }
        return $string
    }

    proc decimal {args} {
        #| Try to cast given string into a decimal value with the given precision and/or scale if present.
        qc::args $args -precision ? -scale ? -- string
        set original $string
        # Strip leading zeros if followed by digit
        # This copes with 0 and 00
        regsub {^(-?)0+([0-9].*)$} $string {\1\2} string
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
        return [clock format [epoch $string] -format "%Y-%m-%d %H:%M:%S"]
    }

    proc timestamptz {string} {
        #| Try to convert the given string into an ISO datetime with timezone.
        return [clock format [epoch $string] -format "%Y-%m-%d %H:%M:%S %z"]
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
        if {$value in [qc::memoize qc::db_enum_values $name]} {
            return $value
        } else {
            return -code error -errorcode CAST "Can't cast \"$value\": not a valid value for enumeration \"$name\"."
        }
    }

    proc domain {domain_name value} {
        #| Cast value to the domain $domain_name.
        set base_type [qc::memoize qc::db_domain_base_type $domain_name]
        if { [qc::castable $base_type $value] } {
            set value [qc::cast $base_type $value]
        } else {
            return -code error -errorcode CAST "Can't cast \"[qc::trunc $value 100]...\": not a valid value for base type \"$base_type\" while checking \"$domain_name\" type."
        }

        if { [qc::is $domain_name $value] } {
            return $value
        } else {
            return -code error -errorcode CAST "Can't cast \"[qc::trunc $value 100]...\": not a valid value for \"$domain_name\"."
        }
    }

    proc safe_html {text} {
        #| Cast text to safe html.
        if { [qc::is safe_html $text] } {
            return $text
        } else {
            return -code error -errorcode CAST "Can't cast \"[qc::trunc $text 100]...\": not safe html."
        }
    }

    proc safe_markdown {text} {
        #| Cast text to safe markdown.
        if {[qc::is safe_markdown $text]} {
            return $text
        } else {
            return -code error -errorcode CAST "Can't cast \"[qc::trunc $text 100]...\": not safe markdown."
        }
    }

    proc date {string} {
        #| Try to convert the given string into an ISO date.
        return [clock format [epoch $string] -format "%Y-%m-%d"]
    }

    proc time {time} {
        #| Try to convert the given string into a time,
        # in hh:mm:ss or hh:mm:ss.xxxxxx format
        if { [regexp {^((?:[0-1])?[0-9]|2[0-3]):((?:[0-5])?[0-9]):([0-5][0-9])\.(\d+)$} \
                  $time -> hours minutes seconds subseconds] } {
        } elseif {[regexp {^((?:[0-1])?[0-9]|2[0-3]):((?:[0-5])?[0-9]):([0-5][0-9])$} \
                  $time -> hours minutes seconds] } {
            set subseconds 0
        } elseif {[regexp {^((?:[0-1])?[0-9]|2[0-3]):((?:[0-5])?[0-9])$} \
                       $time -> hours minutes] } {
            set seconds 00
            set subseconds 0
        } elseif { [regexp {^24:00(:00(\.0+)?)?$} $time] } {
            set hours 24
            set minutes 00
            set seconds 00
            set subseconds 0
        } else {
            return -code error -errorcode CAST "Can't cast \"[qc::trunc $time 100]...\": not recognised time."            
        }
        set hours [format %02s $hours]
        set minutes [format %02s $minutes]
        set seconds [format %02s $seconds]
        set subseconds [qc::cast decimal -precision 7 -scale 6 "0.$subseconds"]

        if { $subseconds > 0.0 } {
            set subseconds [string range [string trimright $subseconds 0] 2 end]
            return "${hours}:${minutes}:${seconds}.$subseconds"
            
        } else {
            return "${hours}:${minutes}:${seconds}"
        }
    }

    proc epoch {string} {
        #| Try to convert the given string into an epoch.
        set string [string map [list "&#8209;" -] $string]

        #### EXACT MATCHES ####
        if { [string equal $string ""] } {
            return -code error -errorcode CAST "Can't cast an empty string to epoch"
        }

        # Looks like an eight-digit number, try to interpret as yyyymmdd or ddmmyyyy
        if { [regexp {^\d{8}$} $string] } {

            # Try yyyymmdd
            set year1 [string range $string 0 3]
            set month1 [string range $string 4 5]
            set day1 [string range $string 6 7]

            if { 0 < $month1 && $month1 <= 12
                 &&
                 0 < $day1 && $day1 <= [lindex {
                     - 31 29 31 30 31 30 31 31 30 31 30 31
                 } [string trimleft $month1 0]]
                 &&
                 1990 <= $year1 && $year1 < 2100
             } {
                set date1_valid true
            } else {
                set date1_valid false
            }

            # Try ddmmyyyy
            set year2 [string range $string 4 7]
            set month2 [string range $string 2 3]
            set day2 [string range $string 0 1]

            if { 0 < $month2 && $month2 <= 12
                 &&
                 0 < $day2 && $day2 <= [lindex {
                     - 31 29 31 30 31 30 31 31 30 31 30 31
                 } [string trimleft $month2 0]]
                 &&
                 1990 <= $year2 && $year2 < 2100
             } {
                set date2_valid true
            } else {
                set date2_valid false
            }

            # If one result is valid, return it. If both are, error.
            if { $date1_valid && $date2_valid } {
                return -code error -errorcode CAST "Ambiguous date"

            } elseif { $date1_valid } {
                return [clock scan "$year1-$month1-$day1"]

            } elseif { $date2_valid } {
                return [clock scan "$year2-$month2-$day2"]

            }
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
        if { [regexp {^(\d{1,2})[-/\.](\d{1,2})[-/\.](\d{4}|\d{2}|\d)$} $string -> day month year] } {
            # Assume UK locale dd/mm/yy, dd.mm.yy, or dd-mm-yy
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

        if { [regexp -nocase -- {(year|fortnight|month|week|day|hour|min|sec|tomorrow|yesterday|today|now|last|next|ago)} $string] } {
            return [clock scan $string]
        }

        return -code error -errorcode CAST "Could not cast string to epoch"
    }

    proc postcode {string} {
        #| Try to cast a string into UK Postcode form
        set saved $string
        set postcode [string toupper $string]
        # BFPO 
        if { [string range $postcode 0 3] eq "BFPO" } {
            return $postcode
        }
        # convert AB12CD -> AB1 2CD or AB123CD -> AB12 3CD
        if { [string first " " $postcode] == -1 } {
            set cut [expr {[string length $postcode]-3-1}]
            set postcode "[string range $postcode 0 $cut] [string range $postcode [expr {$cut+1}] end]"
        }
        if { [qc::is postcode $postcode] } {
            return $postcode
        }
        # Convert zero -> CAPITAL O e.g. "Y023 3CD" -> "YO23 3CD"
        regsub {^([A-Z])0([0-9]{1,2}) (.+)$} $postcode {\1O\2 \3} postcode

        if { [qc::is postcode $postcode] } {
            return $postcode
        } else {
            return -code error -errorcode CAST "Could not cast $saved to postcode."
        }
    }

    proc creditcard {string} {
        #| Cast the given string to a credit card number.
        regsub -all {[^0-9]} $string "" number
        if { [qc::is creditcard $number] } {
            return $number
        } else {
            return -code error -errorcode CAST "$number is not a valid credit card number"
        }
    }

    proc period {string} {
        #| Return a pair of dates defining the period.
        set month_names [list Jan January Feb February Mar March Apr April May Jun June Jul July Aug August Sep September Oct October Nov November Dec December]
        set regexp_map [list \$month_names_regexp [join $month_names |]]

        if { [regexp -nocase {^\s*(.*?)\s+to\s+(.*?)\s*$} $string -> period1 period2] } {
            # Period defined by two periods eg "Jan 2011 to March 2011"
            lassign [period $period1] from_date .
            lassign [period $period2] . to_date

        } elseif { [regexp {^\d{4}-\d{2}-\d{2}$} $string] } {
            # String is an iso date eg "2014-01-01"
            set from_date [qc::cast date $string]
            set to_date $from_date

        } elseif { [regexp {^([12]\d{3})$} $string -> year] } {
            # Exact match for year eg "2006"
            set from_date [qc::date_year_start $year-01-01]
            set to_date [qc::date_year_end $year-01-01]

        } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)\s+([12]\d{3})$}] $string -> month_name year] } {
            # Exact match in format "Jan 2006"
            set epoch [clock scan "01 $month_name $year"]
            set from_date [qc::date_month_start $epoch]
            set to_date [qc::date_month_end $epoch]

        } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)$}] $string -> month_name] } {
            # Exact match in format "Jan" (assume current year)
            set epoch [clock scan "01 $month_name [qc::date_year now]"]
            set from_date [qc::date_month_start $epoch]
            set to_date [qc::date_month_end $epoch]

        } elseif { [regexp -nocase -- [string map $regexp_map {^([0-9]{1,2})(?:st|th|nd|rd)?\s+($month_names_regexp)\s+([12]\d{3})$}] $string -> dom month_name year] } {
            # Exact match for castable date in format "1st Jan 2014"
            set epoch [clock scan "$dom $month_name $year"]
            set from_date [date $epoch]
            set to_date $from_date

        } elseif { [regexp -nocase -- [string map $regexp_map {^([0-9]{1,2})(?:st|th|nd|rd)?\s+($month_names_regexp)$}] $string -> dom month_name] } {
            # Exact match for castable date in format "1st Jan" (assume current year)
            set epoch [clock scan "$dom $month_name [qc::date_year now]"]
            set from_date [date $epoch]
            set to_date $from_date

        } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)\s+([0-9]{1,2})(?:st|th|nd|rd)?\s+([12]\d{3})$}] $string -> month_name dom year] } {
            # Exact match for castable date in format "Jan 1st 2014"
            set epoch [clock scan "$dom $month_name $year"]
            set from_date [date $epoch]
            set to_date $from_date

        } elseif { [regexp -nocase -- [string map $regexp_map {^($month_names_regexp)\s+([0-9]{1,2})(?:st|th|nd|rd)?$}] $string -> month_name dom] } {
            # Exact match for castable date in format "Jan 1st" (assume current year)
            set epoch [clock scan "$dom $month_name [qc::date_year now]"]
            set from_date [date $epoch]
            set to_date $from_date

        } else {
            # error - could not parse string
            return -code error -errorcode CAST "Could not parse string \"$string\" into dates that define a period."
        }
        
        return [list $from_date $to_date]
    }

    proc url {string} {
        #| Cast the given string to an url
        #| (See also qc::is url)
        set lower [string tolower $string]
        if { [qc::is url $lower] } {
            return $lower
        }
        if { [qc::is url "http://${lower}"] } {
            return "http://${lower}"
        }
        return -code error -errorcode CAST "Could not cast $string to an url."
    }

    proc relative_url {string} {
        #| Cast the given string to a relative url
        #| (See also qc::is url)
        set lower [string tolower $string]
        if { [qc::is url -relative $lower] } {
            return $lower
        }  
        return -code error -errorcode CAST "Could not cast $string to an url."      
    }
    
    proc url_path {string} {
	#| Cast the given string to an url_path
	#| (See also qc::is url_path)
	set lower [string tolower $string]
	if { [qc::is url_path $lower] } {
	    return $lower
	}
	if { [qc::is url_path "/${lower}"] } {
	    return "/${lower}"
	}
	return -code error -errorcode CAST "Could not cast $string to an url path"
    }

    proc s3_url {string} {
        #| Cast the given string to an s3 url
        #| (See also qc::is s3_url)

        # Split the string into bucket and object key
        lassign [qc::s3_url_bucket_object_key $s3_url] bucket object_key
        if { ![qc::is s3_bucket $bucket] } {
            return -code error -errorcode CAST "Could not cast $string to an s3_url"
        }
        if { $object_key ne "" && ![qc::is s3_object_key $object_key] } {
            return -code error -errorcode CAST "Could not cast $string to an s3_url"
        }
        
        # Force the url to start "S3://"
        set s3_url $string
        if {[regexp {^[sS]3://(.*)$} $s3_url -> temp]} {
            set s3_url $temp
        } elseif {[regexp {^/(.*)$} $s3_url -> temp]} {
            set s3_url $temp
        }
        
        return "s3://${$bucket}/{$object_key}"
    }

    proc interval {string} {
        #| Cast string to interval
        if { [qc::is interval $string] } {
            return [string tolower $string]
        }
	return -code error -errorcode CAST "Could not cast $string to an interval"
    }
}
