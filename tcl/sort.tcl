package provide qcode 2.03
package require doc
namespace eval qc {
    namespace export sortcols_* sortcols2dict
}

proc qc::sortcols_push { sortCols colname {sortorder ASC} } {
    #| take a list of [colname1 order colname2 order ...]
    #| and reorder putting $colname first with order $sortorder
    set newSortCols [list $colname $sortorder]

    for {set i 0} {$i<[llength $sortCols]} {incr i} {
	set this_item [string trim [lindex $sortCols $i]]
	set next_item [string trim [lindex $sortCols [expr {$i+1}]]]
	if { [ne $this_item $colname]} {
	    lappend newSortCols $this_item
	}
	if { [eq [string toupper $next_item] ASC] } {
	    incr i
	} 
	if { [eq [string toupper $next_item] DESC] } {
	    lappend newSortCols DESC
	    incr i
	} 
    }
    return $newSortCols
}

proc qc::sortcols_toggle { sortCols colname } {
    #| Toggle the sort order on colname
    if { [eq [string toupper [dict get $sortCols $colname]] ASC] } {
	dict set sortCols $colname DESC
    } else {
	dict set sortCols $colname ASC
    }
    return $sortCols
}

proc qc::sortcols_parse { args } {
    #| Accept args in format col1,col2,col3 DESC,col4 ASC
    #| or col1 col2 col3 DESC col4 
    #| Returned list col1 col2 col3 DESC ...
    if { [regexp , $args] } {
	set args [string trim $args]
	set args [split $args " ,"]
    }
    set list {}
    for {set i 0} {$i<[llength $args]} {incr i} {
	set this_item [string trim [lindex $args $i]]
	set next_item [string trim [lindex $args [expr {$i+1}]]]
	if { [eq [string toupper $next_item] ASC] } {
	    lappend list $this_item
	    incr i 
	} elseif {[eq [string toupper $next_item] DESC] } {
	    lappend list $this_item [string toupper $next_item]
	    incr i
	} else {
	    lappend list $this_item
	}
    }
    return $list
}

proc qc::sortcols2dict { args } {
    #| Accept args in format col1,col2,col3 DESC,col4 ASC
    #| or col1 col2 col3 DESC col4 
    #| Returned list col1 ASC col2 ASC col3 DESC ...
    if { [regexp , $args] } {
	set args [string trim $args]
	set args [split $args " ,"]
    }
    set list {}
    for {set i 0} {$i<[llength $args]} {incr i} {
	set this_item [string trim [lindex $args $i]]
	set next_item [string trim [lindex $args [expr {$i+1}]]]
	if { [eq [string toupper $next_item] ASC] } {
	    lappend list $this_item ASC
	    incr i 
	} elseif {[eq [string toupper $next_item] DESC] } {
	    lappend list $this_item DESC
	    incr i
	} else {
	    lappend list $this_item ASC
	}
    }
    return $list
}

proc qc::sortcols_from_cols { cols } {
    #| Extract column names from a cols list-of-lists 
    set sortCols {}
    foreach col $cols {
	if { [dict exists $col name] } {
	    lappend sortCols [dict get $col name]
	}
    }
    return $sortCols
}

proc qc::sortcols_from_qry { qry } {
    #| Look for an order by clause in the qry and return a list version
    if { [regexp -nocase {order by (.+?)(offset|limit|$)} $qry -> orderby ignore] } {
	regsub -all {\n} $qry {} qry
	return [qc::sortcols_parse $orderby]
    } else {
	return ""
    }
}


