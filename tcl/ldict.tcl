namespace eval qc {
    namespace export ldict_* ldict2tbody
}

proc qc::ldict_set {ldictVar index key value} {
    #| Takes a list of dicts and sets the value for $key in the dict at $index
    upvar 1 $ldictVar ldict
    set dict [lindex $ldict $index]
    dict set dict $key $value
    lset ldict $index $dict
}

proc qc::ldict_sum { ldictVar key } {
    #| Traverse a dict list and sum all dict values for given key.
    # TODO: could be de-aolserverised, and perhaps should error if we try to add
    # non-decimal strings rather than return 0.
    set sum 0
    upvar 1 $ldictVar ldict
    foreach dict $ldict {
	set value [dict get $dict $key]
	set value [qc::strip_html $value]
	regsub -all {[, ]} $value {} value
	if { [string is double -strict $value] } {
	    set sum [expr {$sum + $value}]
	}
    }
    return $sum
}

proc qc::ldict_max { ldictVar key } {
    set max {}
    upvar 1 $ldictVar ldict
    foreach dict $ldict {
	set value [dict get $dict $key]
	if { [string equal $max ""] } {
	    set max $value
	} else {
	    if { $value > $max } {
		set max $value
	    }
	}
    }
    return $max
}

proc qc::ldict_values { ldictVar key } {
    #| Return a list of the values of this key
    #| in each dict in the ldict
    upvar 1 $ldictVar ldict
    set list {}
    foreach dict $ldict {
	lappend list [dict get $dict $key]
    }
    return $list
}

proc qc::ldict_exists {ldict key} {
    #| Return the first index of the dict that contains the the key $key
    set index 0
    foreach dict $ldict {
	if { [dict exists $dict $key]} {
	    return $index
	}
	incr index
    }
    return -1
}

proc qc::ldict_search {ldictVar key value} {
    #| Return the first index of the dict that contains the value $value for the key $key
    upvar 1 $ldictVar ldict
    set index 0
    foreach dict $ldict {
	if { [dict exists $dict $key] && [dict get $dict $key]=="$value" } {
	    return $index
	}
	incr index
    }
    return -1
}

proc qc::ldict_exclude { ldict key } {
    #| Remove all occurances of $key from the dicts in $ldict
    set newldict {}
    foreach dict $ldict {
	lappend newldict [dict_exclude $dict $key]
    }
    return $newldict
}

proc qc::ldict2tbody {ldict colnames} {
    #| Take a ldict and a list of col names to convert into tbody
    set tbody {}
    foreach dict $ldict {
	set row {}
	foreach colname $colnames {
	    if { [dict exists $dict $colname] } {
		lappend row [dict get $dict $colname]
	    } else {
		lappend row ""
	    }
	}
	lappend tbody $row
    }
    return $tbody
}

proc qc::ldict_mappings_equal {ldict1 ldict2} {
    #| Compare 2 ldicts, for dicts with same mappings
    # (independant of key ordering, but dependant on ldict ordering)
    
    if { ! [string is list $ldict1]
         || ! [string is list $ldict2]
     } {
        return false
    }

    if { [llength $ldict1] != [llength $ldict2] } {
        return false
    }

    # compare each element
    foreach dict1 $ldict1 dict2 $ldict2 {
        if { ! [qc::dict_mappings_equal $dict1 $dict2] } {
            return false
        }
    }
    return true
}
