package provide qcode 1.6
package require doc
namespace eval qc {}

proc qc::dict_subset {dict args} {
    # Return an dict made up of the keys given
    set result {}
    foreach key $args {
	if { [dict exists $dict $key] } {
	    lappend result $key [dict get $dict $key]
	}
    }
    return $result
}

proc qc::dict_exclude {dict args} {
    #return an dict excluding keys given
    set temp {}
    foreach {key value} $dict {
	if { ![in $args $key] } {
	    lappend temp $key $value
	}
    }
    return $temp
}

proc qc::dict_sort {dictVariable} {
    upvar 1 $dictVariable dict
    set llist {}
    foreach {name value} $dict {
	lappend llist [list $name $value]
    }
    set llist [lsort -index 1 $llist]
    set dict {}
    foreach item $llist {
	lappend dict [lindex $item 0] [lindex $item 1] 
    }
    return $dict
}
    
proc qc::dict2xml { dict } {
    set list {}
    foreach {name value} $dict {
        lappend list [qc::xml $name $value]
    }
    return [join $list \n]
}

proc qc::dict_from { args } {
    # Take a list of var names and return a dict
    set dict {}
    foreach name $args {
	upvar 1 $name value
	if { [info exists value] } {
	    lappend dict $name $value
	} else {
	    error "Can't create dict with $name: No such variable"
	}
    }
    return $dict
}

proc qc::dict2vars { dict args } {
    if { [llength $args]==0 } {
	# set all variables
	foreach {name value} $dict {upset 1 $name $value}
    } else {
	# only set named variables
	foreach name $args {
	    if { [dict exists $dict $name] } {
		upset 1 $name [dict get $dict $name]
	    } else {
		if { [uplevel 1 [list info exists $name]] } {
		    uplevel 1 [list unset $name]
		}
	    }
	}
    }
}
