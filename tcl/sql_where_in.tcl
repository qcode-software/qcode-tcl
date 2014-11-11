
package require doc
namespace eval qc {
    namespace export sql_where_in sql_where_in_not
}

proc qc::sql_where_in {args } {
    #| Construct part of a SQL WHERE clause using the IN construct.
    # SQL will test column against list of values.
    qc::args $args -type "" -- column list {default false}

    foreach item $list {
	lappend lquoted [db_quote $item $type]
    }
    if {[llength $list]==0} {
	return $default
    } elseif {[llength $list]==1} {
	return "$column=[lindex $lquoted 0]"
    } else {
	return "$column in ([join $lquoted ,])"
    }
}



proc qc::sql_where_in_not { args } {
    #| Construct part of a SQL WHERE clause using the NOT IN construct.
    # SQL will test column against list of values.
    qc::args $args -type "" -- column list {default true}

    foreach item $list {
	lappend lquoted [db_quote $item $type]
    }
    if {[llength $list]==0} {
	return $default
    } elseif {[llength $list]==1} {
	return "$column<>[lindex $lquoted 0]"
    } else {
	return "$column not in ([join $lquoted ,])"
    }
}


