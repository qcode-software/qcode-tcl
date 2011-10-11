package provide qcode 1.0
package require doc
namespace eval qc {}

proc qc::sql_set {args} {
    foreach name $args {
	lappend set_list "$name=:$name"
    }
    return [join $set_list ,]
}

doc sql_set {
    Parent db
    Usage {sql_set ?varName1 varName2 varName3 ...?}
    Description {
	Take a list of varNames to be used to construct a SQL set statement
    }
    Examples {
	% sql_set name email
	name=:name, email=:email
	%
	%
	% set user_id 1
	% set name Jimmy
	% set email jimmy@foo.com
	%
	% set qry "update users set [sql_set name email] where user_id=:user_id"
	update users set name=:name, email=:email where user_id=:user_id
	%
	# UPDATE THE DATABASE
	% db_dml $qry
    }
}

proc qc::sql_set_varchars_truncate {table args} {
    foreach name $args {
        lappend set_list "${name}=:${name}::varchar([db_col_varchar_length $table $name])"
    }
    return [join $set_list ,]
}

doc sql_set_varchars_truncate {
    Parent db
    Usage {sql_set_varchars_truncate table_name ?varName1 varName2 varName3 ...?}
    Description {
	Take a list of varNames to be updated into varchar columns, and will construct a SQL set statement which will cast the values into the appropriate column's varchar size (effectively truncating the data if too long for the column).
        Useful when the data is being supplied by a third party who's data model may not match the table's.
    }
    Examples {
	% sql_set_varchars_truncate orders delivery_name delivery_address1
	delivery_name=:delivery_name::varchar(50),delivery_address1=:delivery_address1::varchar(100)
    }
}


proc qc::sql_set_with {args} {
    foreach {name value} $args {
	lappend set_list "\"$name\"=[db_quote $value]"
    }
    return [join $set_list ,]
}

proc qc::sql_insert { args } {
    foreach name $args {
	lappend cols $name
	lappend values ":$name"
    }
    return "( [join $cols ,] ) values ( [join $values ,] )" 
}

doc sql_insert {
    Parent db
    Usage {sql_insert varName1 ?varName2 varName3 ...?}
    Description {
	Construct a SQL INSERT statement using varNames given.
    }
    Examples {
	% sql_insert user_id name email password
	(user_id,name,email,password) VALUES (:user_id,:name,:email,:password)
	%
	% set qry "insert into users [sql_insert user_id name email password]"
	insert into users (user_id,name,email,password) VALUES (:user_id,:name,:email,:password)
	%
	% set user_id 3
	% set name Bob
	% set email bob@monkhouse.com
	% set password joke
	% 
	% db_dml $qry
    }
}

proc qc::sql_insert_with { args } {
    foreach {name value} $args {
	lappend cols "\"$name\""
	lappend values [db_quote $value]
    }
    return "( [join $cols ,] ) values ( [join $values ,] )" 
}

proc qc::sql_sort { args } {
    args $args -paging -limit ? -- args
    #| Create the sql for sorting and paging from form_vars
    #| Default sort order can be specified in args

    # Accept args in format col1,col2,col3 DESC,col4 ASC
    # or col1 col2 col3 DESC col4 
    # Returned normal SQL order by clause

    if { [form_var_exists sortCols] } {
        set string [form_var_get sortCols]
    } else {
	if { [llength $args]==1 } {set args [lindex $args 0]}
        set string $args
    } 

    if { [regexp , $string] } {
	set list [split $string ","]
    } else {
	set list $string
    }
    set order_by_list {}
    for {set i 0} {$i<[llength $list]} {incr i} {
	set this_item [lindex $list $i]
	set next_item [lindex $list [expr {$i+1}]]
	if { [eq [string toupper $next_item] ASC] } {
	    lappend order_by_list $this_item
	    incr i
	} elseif { [eq [string toupper $next_item] DESC] } {
	    lappend order_by_list "$this_item DESC"
	    incr i
	} else {
	    lappend order_by_list "$this_item"
	}
    }
    if { [llength $order_by_list]==0 } {
	# postgresql syntax for 1st column
	set sql "1"
    } else {
	set sql [join $order_by_list ,]
    }

    # Paging
    if { [info exists limit] || [info exists paging] } {
        # We are paging
        if { [form_var_exists limit] && [is_integer [form_var_get limit]] } {
            #formvar trumps everything
            set limit [form_var_get limit]
        } elseif { [info exists limit] } {
            # -limit option was used and limit is already set
        } elseif { [uplevel 1 {info exists limit}] } {
            #limit is set in callers namespace
            upcopy 1 limit limit
        } else {
            #it's not set anywhere - use a default
            set limit 100
        }
            
        # make sure it's set in caller's namespace
        upset 1 limit $limit

        if { [form_var_exists offset] && [is_integer [form_var_get offset]]} {
            set offset [form_var_get offset]
        } else {
            set offset 0
        }
        upset 1 offset $offset

        return "$sql limit $limit offset $offset"
    } else {
	return $sql
    }
}

doc sql_sort {
    Parent db
    Usage {sql_sort colName1 ?colName2 colName3 ...?}
    Examples {
	% sql_sort name email
	name,email
	%
	% sql_sort name DESC,email ASC
	name DESC,email
	% sql_sort -paging name,email
	name,email limit 100 offset 0
    }
}

proc qc::sql_select_case_month { date_col value_col {alt_value 0} {col_names {jan feb mar apr may jun jul aug sep oct nov dec}}} {
    set alt_value [db_quote $alt_value]
    foreach month {1 2 3 4 5 6 7 8 9 10 11 12} {
	lappend list "CASE WHEN extract(month from $date_col)=$month THEN $value_col ELSE $alt_value END as [lindex $col_names [expr {$month-1}]]"
    }
    return [join $list ,\n]
}

proc qc::sql_in {list} {
     set sql {}
    foreach value $list {
	lappend sql [db_quote $value]
    }
    if { [llength $sql]==0 } {
	return "(NULL)"
    } else {
	return "([join $sql ,])"
    }
}

proc qc::sql_array2list {array} {
    set list [csv2list [string map [list \{ "" \} "" \\\" \"\"] $array]]
    return [lreplace_values $list NULL ""]
}

proc qc::sql_list2array {list} {
    foreach item $list {
	lappend lquoted [db_quote $item]
    }
    if {[llength $list]==0} {
	return \{\}
    } else {
	return \{[join $lquoted ,]\}
    }
}
