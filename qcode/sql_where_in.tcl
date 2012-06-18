package provide qcode 1.5
package require doc
namespace eval qc {}
proc qc::sql_where_in {column list {default false} } {
    # Construct part of a SQL WHERE clause using the IN construct.
    # SQL will test column against list of values.
    foreach item $list {
	lappend lquoted [db_quote $item]
    }
    if {[llength $list]==0} {
	return $default
    } elseif {[llength $list]==1} {
	return "$column=[lindex $lquoted 0]"
    } else {
	return "$column in ([join $lquoted ,])"
    }
}

doc sql_where_in {
    Parent db
    Usage {sql_where_in colName list ?defaultValue?}
    Description {
	Construct part of a SQL WHERE clause using the IN construct.<br>
	SQL will test column against list of values.
	If list is empty return default value (normally false).
    }    
    Examples {
	% sql_where_in name {Jimmy Bob Des}
	name in ('Jimmy','Bob','Des')
	%
	% sql_where_in t.status_id [list 1 3 5 6]
	t.status_id in (1,3,5,6)
	%
	% sql_where_in col "" true
	true
    }
}

proc qc::sql_where_in_not {column list {default true}} {
    foreach item $list {
	lappend lquoted [db_quote $item]
    }
    if {[llength $list]==0} {
	return $default
    } elseif {[llength $list]==1} {
	return "$column<>[lindex $lquoted 0]"
    } else {
	return "$column not in ([join $lquoted ,])"
    }
}

doc sql_where_in_not {
    Parent db
    Usage {sql_where_in_not colName list ?defaultValue?}
    Description {
	Negation of <proc>sql_where_in</proc>
	Construct part of a SQL WHERE clause using the IN construct.<br>
	SQL will test where column is not in the list of values.
	If list is empty return default value (normally true).
    }    
    Examples {
	% sql_where_in_not name {Jimmy Bob Des}
	name not in ('Jimmy','Bob','Des')
	%
	% sql_where_in_not t.status_id [list 1 3 5 6]
	t.status_id not in (1,3,5,6)
	%
	% sql_where_in_not col ""
	true
    }
}
