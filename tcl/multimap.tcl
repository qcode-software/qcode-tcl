namespace eval qc {
    namespace export multimap_*
}

proc qc::multimap_get_first {args} {
    #| Return the value for the first matching key
    args $args -nocase -glob -regexp -- multimap key
    set switches {}
    foreach switch {nocase glob regexp} {
        if { [info exists $switch] } {
            lappend switches -${switch}
        }
    }
    set index [lsearch {*}$switches [multimap_keys $multimap] $key]

    if { $index > -1 } {
	return [lindex $multimap [expr {($index*2)+1}]]
    } else {
	error "multimap does not contain the key:$key it contains \"$multimap\""
    }
}

proc qc::multimap_set_first {args} {
    #| Set the value of the first matching key
    args $args -nocase -glob -regexp -- multimapVariable key value
    upvar 1 $multimapVariable multimap
    set switches {}
    foreach switch {nocase glob regexp} {
        if { [info exists $switch] } {
            lappend switches -${switch}
        }
    }
    set index [lsearch {*}$switches [multimap_keys $multimap] $key]

    if { $index > -1 } {
	lset multimap [expr {($index*2)+1}] $value
    } else {
	lappend multimap $key $value
    }
}

proc qc::multimap_unset_first { multimapVariable key args } {
    #| Delete the first matching key/value pair from the multimap
    if { [llength $args] > 1 } {
        error "Usage: qc::multimap_unset_first multimapVariable key ?value?"
    }
    upvar 1 $multimapVariable multimap
    if { [llength $args] == 1 } {
        set search_value [lindex $args 0]
        set index 0
        foreach {name value} $multimap {
            if { $name eq $key && $value eq $search_value } {
                set multimap [lreplace $multimap $index [expr {$index+1}]]
                return $multimap
            }
            incr index 2
        }
    } else {
        set search_value [lindex $args 0]
        set index 0
        foreach {name value} $multimap {
            if { $name eq $key } {
                set multimap [lreplace $multimap $index [expr {$index+1}]]
                return $multimap
            }
            incr index 2
        }
    }
}

proc qc::multimap_exists { args } {
    #| Check if a value exists for this key
    args $args \
        -nocase \
        -glob \
        -regexp \
        -- \
        multimap \
        key

    set switches [list]

    foreach switch {nocase glob regexp} {
        if { [info exists $switch] } {
            lappend switches -${switch}
        }
    }

    if { [lsearch {*}$switches [multimap_keys $multimap] $key] > -1 } {
	return 1
    } else {
	return 0
    }
}

proc qc::multimap_keys {multimap} {
    #| Return a list of keys in the multimap
    set keys {}
    foreach {key value} $multimap {
	lappend keys $key
    }
    return $keys
}

proc qc::multimap_get_all { multimap key } {
    #| Return all value for this key
    set list {}
    foreach index [lsearch -all $multimap $key] {
	if { $index%2 == 0 } {
	    lappend list [lindex $multimap [expr {$index+1}]]
	}
    }
    return $list
}

