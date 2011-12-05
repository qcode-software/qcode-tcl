package provide qcode 1.2
package require doc
namespace eval qc {}

if {![llength [info commands dict]]} {
    proc dict {cmd args} {
	uplevel 1 [linsert $args 0 qc::dict_$cmd]
    }
}

proc qc::dict_create { args } {
    if { [llength $args]==1 } {set args [lindex $args 0]}
    set dict {}
    foreach {name value} $args {
	dict_set dict $name $value
    }
    return $dict
    #array set array $args
    #return [array get array]
}

proc qc::dict_get { dict key } {
    set index [lsearch -exact $dict $key]
    while { $index%2!=0 && $index!=-1 && $index<[llength $dict]} {
	incr index
	set index [lsearch -exact -start $index $dict $key]
    }
    if { $index%2 == 0 } {
	return [lindex $dict [expr {$index+1}]]
    } else {
	error "dict does not contain the key:$key it contains \"$dict\""
    } 
}

proc qc::dict_set { dictVariable key value } {
    upvar 1 $dictVariable dict
    if { [info exists dict] } {
	set index [lsearch -exact $dict $key]
    } else {
	set index -1
    }
    if { $index%2 == 0 } {
	lset dict [expr {$index+1}] $value
    } else {
	lappend dict $key $value
    }
}

proc qc::dict_unset { dictVariable key } {
    upvar 1 $dictVariable dict
    set index [lsearch -exact $dict $key]
    if { $index%2 == 0 } {
	set dict [lreplace $dict $index [expr {$index+1}]]
    }
}

proc qc::dict_exists { args } {
    args $args dict args

    set key [lindex $args 0]
    set index [lsearch -exact $dict $key]
    while { $index%2!=0 && $index!=-1 && $index<[llength $dict]} {
    incr index
    set index [lsearch -exact -start $index $dict $key]
    }
    if { $index%2 == 0 && [llength $args] > 1 } {
        # key has a value but there are more keys, so recurse with value and rest of keys
        return [dict_exists [lindex $dict [expr {$index+1}]] {*}[lrange $args 1 end]]
    } elseif { $index%2 == 0 && [llength $dict]%2 == 0} {
        # key has value, this is a valid dict and there are no more keys. the end.
        return 1
    } else {
        # key doesn't have value
        return 0
    }
}

proc qc::dict_incr {dictVariable key {value 1}} {
    # Incr a dict value
    upvar 1 $dictVariable dict
    dict_set dict $key [expr {[dict_get $dict $key]+$value}]
}

proc qc::dict_lappend {dictVariable key args} {
    # Incr a dict value
    upvar 1 $dictVariable dict
    if { [dict_exists $dict $key] } {
	set list [dict_get $dict $key] 
	dict_set dict $key [lappend list $args]
    } else {
	dict_set dict $key $args
    }
}

proc qc::dict_keys {dict} {
    set keys {}
    foreach {key value} $dict {
	lappend keys $key
    }
    return $keys
}

proc qc::dict_subset {dict args} {
    # Return an dict made up of the keys given
    if { [llength $args]==1 } {set args [lindex $args 0]}
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
    if { [llength $args]==1 } {set args [lindex $args 0]}
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
    
proc qc::dict2xml { args } {
    if { [llength $args]==1 } {set args [lindex $args 0]}
    set list {}
    foreach {name value} $args {
        lappend list [qc::xml $name $value]
    }
    return [join $list \n]
}

proc qc::dict_from { args } {
    # Take a list of var names and return a dict
    if { [llength $args]==1 } {set args [lindex $args 0]}
    
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
    if { [llength $args]==1 } {set args [lindex $args 0]}
    
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
