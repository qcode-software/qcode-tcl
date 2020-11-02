namespace eval qc {
    namespace export dict_exists dict_subset dict_exclude dict_sort dict2xml dict_from dict2vars dict_default dicts_equal dict_intersect
}

proc qc::dict_exists { args } {
    #| Return true if the given key (or path to key) exists. 
    #| Otherwise return false.

    #| Unlike dict exists command, do not fail if path to key does not exist.
    #| Eg: dict_exists [dict create a 1 b 2 c 3] a a1
    #
    # This is fixed apparently in Tcl8.5.12
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

proc qc::dict_subset {dict args} {
    #| Return a dict made up of the keys given.
    set result {}
    foreach key $args {
	if { [dict exists $dict $key] } {
	    lappend result $key [dict get $dict $key]
	}
    }
    return $result
}

proc qc::dict_exclude {dict args} {
    #| Return an dict excluding the keys given.
    set temp {}
    foreach {key value} $dict {
	if { ![in $args $key] } {
	    lappend temp $key $value
	}
    }
    return $temp
}

proc qc::dict_sort {dictVariable} {
    #| Sort the top level dict contained in dictVariable by ascending key values.
    #| Write the resulting dict back to dictVariable and return the sorted dict.
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
    #| Convert top level {key value} pairs in dict value to xml elements.
    #| Return xml.
    set list {}
    foreach {name value} $dict {
        lappend list [qc::xml $name $value]
    }
    return [join $list \n]
}

proc qc::dict_from { args } {
    #| Take a list of var names and return a dict.
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
    #| Set all or a subset of the {key value} pairs in dict as variables in the caller.
    #|
    #| If a list of keys is provided only set corresponding variables.
    #| If any of the keys do not exist in the dict unset the variable in the caller if it exists.
    if { [llength $args]==0 } {
	# set all variables
	foreach {name value} $dict {
            upset 1 $name $value
        }
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

proc qc::dict_default {dictVar args} {
    #| Set default values in the dict if they do not exist
    foreach {name value} $args {
        upvar 1 $dictVar dict
        if { ![dict exists $dict $name] } {
            dict set dict $name $value
        }
    }
    return $dict
}

proc qc::dict_zipper {keys values} {
    #| Creates a dictionary by pairing up each key and value from the provided lists.
    set zipped ""
    foreach key $keys value $values {
        dict set zipped $key $value
    }
    return $zipped
}

proc qc::dicts_equal {dict1 dict2} {
    #| Compare 2 dicts for equivalence
    if { [dict size $dict1] != [dict size $dict2] } {
        return false
    }
    foreach {key1 value1} $dict1 {key2 value2} $dict2 {
        if { $key1 ne $key2
             ||
             $value1 ne $value2 } {
            return false
        }
    }
    return true
}

proc qc::dict_intersect {dict1 dict2} {
    #| Returns a dict with key value pairs that
    # are present in both dict1 and dict2
    set result [dict create]

    foreach {key value} $dict1 {
        if { [dict exists $dict2 $key] && [dict get $dict2 $key] eq $value } {
            dict set result $key $value
        }
    }

    return $result    
}

proc qc::dict_is_subset {dict1 dict2} {
    #| Check if dict1 is a subset of dict2
    return [dicts_equal [dict_intersect $dict1 $dict2] $dict1]
}
