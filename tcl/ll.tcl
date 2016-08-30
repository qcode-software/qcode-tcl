namespace eval qc {
    namespace export ll_sum ll2csv
}

proc qc::ll_sum { llVar index } {
    #| Traverses a list of lists and returns the sum of values at $index in each list
    # TODO: Could be de-aolserverised
    set sum 0
    upvar 1 $llVar ll
    foreach list $ll {
	set value [lindex $list $index]
	set value [qc::strip_html $value]
	regsub -all {[, ]} $value {} value
	if { [string is double -strict $value] } {
	    set sum [expr {$sum + $value}]
	}
    }
    return $sum
}

proc qc::ll2csv {ll {comma ,}} {
    #| Convert a list of lists into a csv.
    #| Defaults to comma separated but allows the passing of alternative delimiters.
    set lines {}
    foreach list $ll {
	lappend lines [qc::list2csv $list $comma]
    }
    return [join $lines \r\n]
}

proc qc::ll2pg_copy {ll} {
    #| Return data in the format accepted by postgresql's copy statements
    set pg_copy_data ""
    foreach list $ll {
        append pg_copy_data "[qc::list2pg_copy $list]\n"
    }
    return $pg_copy_data
}

proc qc::list2pg_copy {list} {
    #| Return data in the format accepted by postgresql's copy statements
    set temp {}
    foreach value $list {
        if { $value eq "" } {
            # Encode empty string as NULL
            set value \\N
        } else {
            # Escape backslash, newline, carriage return, tab characters
            set value [string map {\\ \\\\ \n \\n \r \\r \t \\t \v \\v} $value]
        }
        lappend temp $value
    }
    return "[join $temp \t]"
}


