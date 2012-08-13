package provide qcode 1.7
package require doc
namespace eval qc {}

proc qc::multimap_get_first { multimap key } {
    set index [lsearch $multimap $key]
    if { $index%2 == 0 } {
	return [lindex $multimap [expr {$index+1}]]
    } else {
	error "multimap does not contain the key:$key it contains \"$multimap\""
    }
}

proc qc::multimap_set_first { multimapVariable key value } {
    upvar 1 $multimapVariable multimap
    set index [lsearch $multimap $key]
    if { $index%2 == 0 } {
	lset multimap [expr {$index+1}] $value
    } else {
	lappend multimap $key $value
    }
}

proc qc::multimap_unset_first { multimapVariable key } {
    upvar 1 $multimapVariable multimap
    set index [lsearch $multimap $key]
    if { $index%2 == 0 } {
	set multimap [lreplace $multimap $index [expr {$index+1}]]
    }
}

proc qc::multimap_exists { multimap key } {
    # Check if a value exists for this key
    if { [lsearch $multimap $key]%2 == 0} {
	return 1
    } else {
	return 0
    }
}

proc qc::multimap_keys {multimap} {
    set keys {}
    foreach {key value} $multimap {
	lappend keys $key
    }
    return $keys
}

proc qc::multimap_get_all { multimap key } {
    set list {}
    foreach index [lsearch -all $multimap $key] {
	if { $index%2 == 0 } {
	    lappend list [lindex $multimap [expr {$index+1}]]
	}
    }
    return $list
}
