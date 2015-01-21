namespace eval qc {
    namespace export table_foreach table2ldict table2array table_sum
}

proc qc::table_foreach { table code } {
    # Loop through a table setting local variables with values in the row
    # named using the first row.
    # Then execute code given for every row.
    set keys [lindex $table 0]
    foreach list [lrange $table 1 end] {
	foreach key $keys value $list {
	    upset 1 $key $value
	}
	uplevel 1 $code
    }
}

proc qc::table2ldict { table } {
    #| Convert a table to an ldict (list of dicts)
    set ldict {}
    set keys [lindex $table 0]
    foreach list [lrange $table 1 end] {
	set dict {}
	foreach key $keys value $list {
	    lappend dict $key $value
	}
	lappend ldict $dict
    }
    return $ldict
}

proc qc::table2array { table args } {
    # Attempt at cross tab stuff 
    array set data {}
    set keys [lindex $table 0]
    table_foreach $table {
	foreach varname [lexclude $keys {*}$args] {
	    set pkeys {}
	    foreach key $args {
		lappend pkeys [set $key]
	    }
	    lappend pkeys $varname
	    set pk [join $pkeys ,]
	    set data($pk) [set $varname]
	}
    }
    return [array get data]
}

proc qc::table_sum { table col_name } {
    #| Return the sum of values in a column
    set sum 0
    set col_index [lsearch [lindex $table 0] $col_name]
    foreach row_index [.. 1 [expr {[llength $table]-1}]] {
	set value [lindex $table $row_index $col_index]
	if { [qc::is decimal $value] } {
	    incr0 sum $value
	}
    }
    return $sum
}
