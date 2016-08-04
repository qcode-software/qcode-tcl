namespace eval qc {
    namespace export sql_set sql_set_varchars_truncate sql_set_with sql_insert sql_insert_with sql_sort sql_select_case_month sql_in sql_array2list sql_list2array sql_where_postcode sql_insert_or_update sql_insert_or_update_with sql_limit
}

proc qc::sql_set {args} {
    foreach name $args {
	lappend set_list "$name=:$name"
    }
    return [join $set_list ,]
}

proc qc::sql_set_varchars_truncate {table args} {
    foreach name $args {
        lappend set_list "${name}=:${name}::varchar([db_col_varchar_length $table $name])"
    }
    return [join $set_list ,]
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

proc qc::sql_insert_with { args } {
    #| Construct a SQL INSERT statement using the name value pairs given
    foreach {name value} $args {
	lappend cols "\"$name\""
	lappend values [db_quote $value]
    }
    return "( [join $cols ,] ) values ( [join $values ,] )" 
}

proc qc::sql_sort { args } {
    args $args -paging -limit ? -nulls last -- args
    #| Create the sql for sorting and paging from form_vars
    #| Default sort order can be specified in args

    # Accept args in format col1,col2,col3 DESC,col4 ASC
    # or col1 col2 col3 DESC col4 
    # Returned normal SQL order by clause

    if { [form_var_exists sortCols] } {
        set string [form_var_get sortCols]
    } else {
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
        set this_item [string trim $this_item]
        set this_item [qc::db_quote_identifier $this_item]

	set next_item [lindex $list [expr {$i+1}]]
        set next_item [string trim $next_item]

	switch -nocase $next_item {
	    ASC {
		if { [string toupper $nulls] eq "FIRST" } {
		    # override default null sorting order
		    lappend order_by_list "$this_item NULLS FIRST"
		} else {
		    # default null sorting order for ASC (NULLS LAST)
		    lappend order_by_list $this_item
		}
		incr i
	    }
	    DESC {
		if { [string toupper $nulls] eq "LAST" } {
		    # override default null sorting order
		    lappend order_by_list "$this_item DESC NULLS LAST"
		} else {
		    # default null sorting order for DESC (NULLS FIRST)
		    lappend order_by_list "$this_item DESC"
		}
		incr i
	    }
	    default {
		if { [string toupper $nulls] eq "FIRST" } {
		    # override default null sorting order
		    lappend order_by_list "$this_item NULLS FIRST"
		} else {
		    # default null sorting order (NULLS LAST)
		    lappend order_by_list $this_item
		}
	    }
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
        if { [form_var_exists limit] && [qc::is integer [form_var_get limit]] } {
            #formvar trumps everything
            set limit [form_var_get limit]
        } elseif { [info exists limit] } {
            # -limit option was used and limit is already set
        } elseif { [uplevel 1 {info exists limit}] } {
            #limit is set in callers namespace
            qc::upcopy 1 limit limit
        } else {
            #it's not set anywhere - use a default
            set limit 100
        }
            
        # make sure it's set in caller's namespace
        upset 1 limit $limit

        if { [form_var_exists offset] && [qc::is integer [form_var_get offset]]} {
            set offset [form_var_get offset]
        } else {
            set offset 0
        }
        upset 1 offset $offset

        return "$sql limit [qc::db_quote $limit] offset [qc::db_quote $offset]"
    } else {
	return $sql
    }
}

proc qc::sql_select_case_month { date_col value_col {alt_value 0} {col_names {jan feb mar apr may jun jul aug sep oct nov dec}}} {
    #| SQL case for crosstab style queries
    set alt_value [db_quote $alt_value]
    foreach month {1 2 3 4 5 6 7 8 9 10 11 12} {
	lappend list "CASE WHEN extract(month from $date_col)=$month THEN $value_col ELSE $alt_value END as [lindex $col_names [expr {$month-1}]]"
    }
    return [join $list ,\n]
}

proc qc::sql_in {list {type ""}} {
    #| Return a SQL comma separated list
    set sql {}
    foreach value $list {
	lappend sql [db_quote $value $type]
    }
    if { [llength $sql]==0 } {
	return "(NULL)"
    } else {
	return "([join $sql ,])"
    }
}

proc qc::sql_array2list {array} {
    # Convert Postgresql 1-dimensional Array to a Tcl list
    set list [csv2list [string map [list \{ "" \} "" \\\" \"\"] $array]]
    return [lreplace_values $list NULL ""]
}

proc qc::sql_list2array { args } {
    #| Convert a list into a PostgrSQL array literal.
    qc::args $args -type "" -- list
    foreach item $list {
	lappend lquoted [db_quote $item $type]
    }
    if { $type ne ""} {
        set sql_cast "::${type}\[\]"
    } else {
        set sql_cast ""
    }
    if {[llength $list]==0} {
	return array\[\]$sql_cast
    } else {
	return array\[[join $lquoted ,]\]$sql_cast
    }
}

proc qc::sql_where_postcode {column postcode} {
    #| Search for rows matching this full or partial UK postcode.
    # Eg. [sql_where_postcode "delivery_postcode" "IV"] matches "IV1 5DZ", "IV10 5DZ" etc.
    #     [sql_where_postcode "delivery_postcode" "I"] matches "I0 5DZ", "I10 5DZ" etc
    set postcode [string toupper $postcode]
    set area_regexp {[A-Z]{1,2}}
    set district_regexp {[0-9][0-9]?[A-Z]?}
    set space_regexp {\s}
    set sector_regexp {[0-9]}
    set unit_regexp {[A-Z]{2}}
    set parse_regexp "
        ^
        ( \$ | ${area_regexp} )
        ( \$ | ${district_regexp} )
        ( \$ | ${space_regexp} )
        ( \$ | ${sector_regexp} )
        ( \$ | ${unit_regexp} )
        $
    "
    
    # Parse postcode extracting area, district, sector and unit.
    if { ! [regexp -expanded $parse_regexp $postcode match area district space sector unit] } {
        error "Unable to parse postcode \"$postcode\""
    }
    
    # Build regexp
    set regexp {^}
    foreach var [list area district space sector unit] {
        if { [set $var] ne "" && $var ne "space" } {
            append regexp [db_escape_regexp [set $var]]
        } else {
            append regexp [set ${var}_regexp]
        }
    }
    append regexp {$}
    
    return [db_qry_parse "$column ~ :regexp"]
}

proc qc::sql_insert_or_update_with {table primary_key_cols dict} {
    #| Run an insert or update query against this table after checking the primary key for existence.
    # Pass column name/value pairs in the dict
    if { [llength $primary_key_cols]==0 } {
        error "You must specify one or more primary key columns"
    }
    set list {}
    foreach col $primary_key_cols {
        lappend list "\"$col\"=[db_quote [dict get $dict $col]]"
    }
    set sql_where [join $list " and "]
    db_1row "
        select count(*) as count
        from \"$table\"
        where $sql_where
    "
    if { $count > 0 } {
        return "
            update \"$table\"
            set [sql_set_with {*}[dict_exclude $dict {*}$primary_key_cols]]
            where $sql_where
        "
    } else {
        return "
            insert into \"$table\"
            [sql_insert_with {*}$dict]
        "
    }
}

proc qc::sql_insert_or_update {table primary_key_cols cols} {
    #| Run an insert or update query against this table after checking the primary key for existence.
    # Pass column name/value pairs in the dict
    set list {}
    foreach col $primary_key_cols {
        lappend list "$col=:$col"
    }
    set sql_where [join $list " and "]
    set qry "
        select count(*) as count
        from \"$table\"
        where $sql_where
    "
    uplevel 1 [list db_1row $qry]
    upvar 1 count count
    if { $count > 0 } {
        return "
            update \"$table\"
            set [sql_set {*}$cols] 
            where $sql_where
        "
    } else {
        return "
            insert into \"$table\"
            [sql_insert {*}$primary_key_cols {*}$cols]
        "
    }
}

proc qc::sql_limit {limit} {
    #| Helper to construct limit clause
    if { $limit ne "" } {
        return "limit [db_quote $limit]"
    } else {
        return ""
    }
}
