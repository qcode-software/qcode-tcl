
package require doc
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

doc qc::ll_sum {
    Description {
        Traverses a list of lists and returns the sum of values at $index in each list
    }
    Usage {
        qc::ll_sum llVar index
    }
    Examples {
        1> set llist [list {widget_a 9.99 19} {widget_b 8.99 19} {widget_c 7.99 1}]
        {widget_a 9.99 19} {widget_b 8.99 19} {widget_c 7.99 1}
        2> qc::ll_sum llist 2
        39
    }
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

doc qc::ll2csv {
    Description {
        Convert a list of lists into a csv.
        Defaults to comma separated but allows the passing of alternative delimiters.
    }
    Usage {
        qc::ll2csv llist ?separator?
    }
    Examples {
        % set llist [list {widget_a 9.99 19} {widget_b 8.99 19} {widget_c 7.99 1}]
        {widget_a 9.99 19} {widget_b 8.99 19} {widget_c 7.99 1}

        % qc::ll2csv $llist
        widget_a,9.99,19
        widget_b,8.99,19
        widget_c,7.99,1

        % qc::ll2csv $llist |
        widget_a|9.99|19
        widget_b|8.99|19
        widget_c|7.99|1
    }
}

proc qc::ll2pg_copy {ll} {
    #| Return data in the format accepted by postgresql's copy statements
    set pg_copy_data ""
    foreach list $ll {
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
        append pg_copy_data "[join $temp \t]\n"
    }
    return $pg_copy_data
}

doc qc::ll2pg_copy {
    Parent db
    Usage {ll2pg_copy ll}
    Description {
	Convert a list of lists data structure into the format accepted by postgresql's copy statements
    }
    Examples {
	% qc::ll2pg_copy [list [Daniel Clark daniel@qcode.co.uk] [list Bernhard "van Woerden" bernhard@qcode.co.uk] [list David Osborne david@qcode.co.uk]]
	Daniel	Clark	daniel@qcode.co.uk
        Bernhard	van Woerden	bernhard@qcode.co.uk
        David	Osborne	david@qcode.co.uk
        
        %
    }
}