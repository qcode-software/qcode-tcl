package provide qcode 2.0
package require doc
namespace eval qc {}

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

doc qc::dict_exists {
    Usage {
	qc::dict_exists dict ?key? ?key? ...
    }
    Examples {
	% set dict {a 1 b {b1 1 b2 2} c 3}
	a 1 b {b1 1 b2 2} c 3
	
	% qc::dict_exists $dict a
	1
	
	% qc::dict_exists $dict b b1
	1
	
	% qc::dict_exists $dict d
	0
	
	% qc::dict_exists $dict c d
	0
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

doc qc::dict_subset {
    Usage {
	qc::dict_subset dict ?key? ?key? ...
    }
    Examples {
	% set dict {a 1 b {b1 1 b2 2} c 3}
	a 1 b {b1 1 b2 2} c 3
	
	% qc::dict_subset $dict a
	a 1
	
	% qc::dict_subset $dict b c
	b {b1 1 b2 2} c 3
	
	% qc::dict_subset $dict c d
	c 3
	
	% qc::dict_subset $dict d
	 
    }
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

doc qc::dict_exclude {
    Usage {
	qc::dict_exclude dict ?key? ?key? ...
    }
    Examples {
	% set dict {a 1 b {b1 1 b2 2} c 3}
	a 1 b {b1 1 b2 2} c 3
	
	% qc::dict_exclude $dict a
	b {b1 1 b2 2} c 3
	
	% qc::dict_exclude $dict b c
	a 1
	
	% qc::dict_exclude $dict c d
	a 1 b {b1 1 b2 2}
	
	% qc::dict_exclude $dict d
	a 1 b {b1 1 b2 2} c 3
    }
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
    
doc qc::dict_sort {
    Examples {
	% set dict {a 1 b 3 c 2}
	a 1 b 3 c 2
	
	% qc::dict_sort dict
	a 1 c 2 b 3
	
	% set dict
	a 1 c 2 b 3
    }
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

doc qc::dict2xml {
    Examples {
	% set dict {a 1 b 2 c 3}
	a 1 b 2 c 3
	
	% qc::dict2xml $dict
	<a>1</a>
	<b>2</b>
	<c>3</c>
    }
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

doc qc::dict_from {
    Usage {
	qc::dict_from ?varName? ?varName? ...
    }
    Examples {
	% set a 1; set b 2; set c 3
	
	% qc::dict_from a b
	a 1 b 2 

	% qc::dict_from c d
	Can't create dict with d: No such variable
    }
}

proc qc::dict2vars { dict args } {
    #| Set all or a subset of the {key value} pairs in dict as variables in the caller.
    #|
    #| If a list of keys is provided only set corresponding variables.
    #| If any of the keys do not exist in the dict unset the variable in the caller if it exists.
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

doc qc::dict2vars {
    Usage {
	qc::dict2vars dict ?varName? ?varName? ...
    }
    Examples {
	% set dict { a 1 b 2 c 3}
	a 1 b 2 c 3
	% set d 4
	4
	
	% qc::dict2vars $dict
	% puts "a:$a, b:$b, c:$c, d:$d"
	a:1, b:2, c:3, d:4

	% qc::dict2vars $dict a b
	% puts "a:$a, b:$b"
	a:1, b:2

	% qc::dict2vars $dict a b d
	% puts "a:$a, b:$b, d:$d"
	can't read "d": no such variable
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
