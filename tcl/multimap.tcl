package provide qcode 2.6.2
package require doc
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
    set index [lsearch {*}$switches $multimap $key]

    if { $index%2 == 0 } {
	return [lindex $multimap [expr {$index+1}]]
    } else {
	error "multimap does not contain the key:$key it contains \"$multimap\""
    }
}

doc qc::multimap_get_first {
    Examples {
	% set multimap [list from John from Jill from Gail to Kim subject Hi]
	from John from Jill from Gail to Kim subject Hi
	% qc::multimap_get_first $multimap from
	John
	% qc::multimap_get_first -nocase $multimap FROM
	John
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
    set index [lsearch {*}$switches $multimap $key]

    if { $index%2 == 0 } {
	lset multimap [expr {$index+1}] $value
    } else {
	lappend multimap $key $value
    }
}

doc qc::multimap_set_first {
    Examples {
	% set multimap [list from John from Jill from Gail to Kim subject Hi]
	from John from Jill from Gail to Kim subject Hi
	% qc::multimap_set_first multimap from Johnny
	from Johnny from Jill from Gail to Kim subject Hi
        % qc::multimap_set_first -nocase multimap FROM Johnny
	from Johnny from Jill from Gail to Kim subject Hi
    }
}

proc qc::multimap_unset_first { multimapVariable key } {
    #| Delete the first matching key/value pair from the multimap
    upvar 1 $multimapVariable multimap
    set index [lsearch $multimap $key]
    if { $index%2 == 0 } {
	set multimap [lreplace $multimap $index [expr {$index+1}]]
    }
}

doc qc::multimap_unset_first {
    Examples {
	% set multimap [list from John from Jill from Gail to Kim subject Hi]
	from John from Jill from Gail to Kim subject Hi
	% qc::multimap_unset_first multimap from
	from Jill from Gail to Kim subject Hi
    }
}

proc qc::multimap_exists { multimap key } {
    #| Check if a value exists for this key
    if { [lsearch $multimap $key]%2 == 0} {
	return 1
    } else {
	return 0
    }
}

doc qc::multimap_exists {
    Examples {
	% set multimap [list from John from Jill from Gail to Kim subject Hi]
	from John from Jill from Gail to Kim subject Hi
	% qc::multimap_exists $multimap subject
	1
	% qc::multimap_exists $multimap foo
	0
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

doc qc::multimap_keys {
    Examples {
	% set multimap [list from John from Jill from Gail to Kim subject Hi]
	from John from Jill from Gail to Kim subject Hi
	% qc::multimap_keys $multimap
	from from from to subject
    }
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

doc qc::multimap_get_all {
    Examples {
	% set multimap [list from John from Jill from Gail to Kim subject Hi]
	from John from Jill from Gail to Kim subject Hi
	% qc::multimap_get_all $multimap from
	John Jill Gail
	% 
    }
}
