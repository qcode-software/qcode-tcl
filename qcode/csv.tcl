package provide qcode 1.0
package require doc
namespace eval qc {}
proc qc::csv2list {csv} {
    return [lindex [qc::csv2ll $csv] 0]
}

proc qc::csv2ll {csv } {
    #| Convert csv data to a list of lists
    #| Accepts csv quoted fields separated by commas with records terminated by newlines.
    #| Commas and newlines may appear inside a quoted field.
    # Windows -> UNIX
    regsub -all {\r\n} $csv \n csv
    
    # Optimized for csv with no quotes
    if {[string first \" $csv]==-1} {
	# trim whitespace around fields
	regsub -all {(^|\n|,) +} $csv {\1} csv
	regsub -all { +(^|\n|,)} $csv {\1} csv
	set result {}
	foreach line [split $csv \n] {
	    lappend result [split $line ,]
	}
	return $result
    }

    # Escape commas embedded in quoted fields with \0
    # Escape newlines embedded in quoted fields with \1
    # Escape double quotes embedded in quoted fields with \2
    # regsub -all won't work because the regexp need to be applied repeatedly to anchor correctly
    set start 0
    while { $start<[string length $csv] && \
		[regexp -expanded -indices -start $start -- {
		    (^|\n|,)
		    \"
		    (
		     ([^\"]|\"\")*
		     (,|\n|"")
		     ([^\"]|\"\")*
		     )
		    \"
		    (,|\n|$)
		} $csv -> . field .] } {
	set field_value [string range $csv [lindex $field 0] [lindex $field 1]]
	set csv [string replace $csv [lindex $field 0] [lindex $field 1] [string map [list , \0 \n \1 \"\" \2] $field_value]]
	set start [expr {[lindex $field 0]+[string length $field_value]+1}]
    }


    set csv [string map {, \0 \0 ,} $csv] 
    # trim whitespace
    regsub -all {(^|\n|\0) +} $csv {\1} csv
    regsub -all { +(^|\n|\0)} $csv {\1} csv
    # remove quotes - no longer needed
    set csv [string map {\" {}} $csv] 

    set result {}
    foreach line [split $csv \n] {
	lappend result [split [string map {\1 \n \2 \"} $line] \0]
    }
    return $result
}

doc csv2ll {
    Examples {
	% set csv {"one","two","three"
4,5,6}
	% csv2ll $csv
	{one two three} {4 5 6}
	%
	set csv {,"one
two","three"",",",""four",","
2,3,4,",
",9}
	% csv2ll $csv
	{{} {one
two} three\", ,\"four ,} {2 3 4 {,
} 9}
    }
}

# This implementation would be fast in c because it scans one time only.
proc qc::OLDcsv2ll {string {quote \"} {comma ,} } {
    # csv to list of lists
    set in false
    set enc false
    set field {}
    set result {}
    set record {}
    set length [string length $string]
    set char ""
    
    # Windows -> UNIX
    regsub -all {\r\n} $string \n string

    for {set i 0} {$i<$length} {incr i} {
	set prev_char $char
	set char [string index $string $i]

	if { ! $in } {
	    # outside
	    if { [string equal $char $comma] } {
		lappend record {}
	    } elseif { [string equal $char \n] } {
		# End of Record
		lappend record {}
		lappend result $record
		set field {}
		set record {}
		set in false
		set enc false
	    } elseif { [string equal $char $quote] } {
		# Start a new enclosed field
		set enc true
		set in true
		# rest char to start for START
		set char ^
	    } else {
		# Start a new non-enclosed field
		append field $char
		set in true
		set enc false
	    }
	} else {
	    # inside
	    if { $enc } {
		# inside and enclosed
		if { [string equal $char $quote] } {
		    if {[string equal $prev_char $quote]} {
			# found quote
			append field $quote
			# reset char to stand for ESCAPED-QUOTE
			set char Q
		    }
		} elseif { [string equal $char $comma] && [string equal $prev_char $quote]} {
		    # End of field
		    lappend record $field
		    set field {}
		    set in false
		    set enc false
		} elseif { [string equal $char \n] && [string equal $prev_char $quote] } {
		    # End of Record
		    lappend record $field
		    lappend result $record
		    set field {}
		    set record {}
		    set in false
		    set enc false
		} else {
		    if { [string equal $char \n] } {
			append field \\n
		    } else {
			append field $char
		    }
		}
	    } else {
		# inside not enclosed
		if { [string equal $char $comma] } {
		    # End of field
		    lappend record $field
		    set field {}
		    set in false
		    set enc false
		} elseif { [string equal $char "\n"] } {
		    # End of record
		    lappend record $field
		    lappend result $record
		    set field {}
		    set record {}
		    set in false
		    set enc false
		} else {
		    append field $char
		}
	    }
	}
    }
    if { $in } {
	# End of Record
	lappend record $field
	lappend result $record
    } else {
	if { [string equal $char ,] } {
	    lappend record {}
	    lappend result $record
	}
    }
    return $result
}

