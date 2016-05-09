namespace eval qc {
    namespace export db_*
}

proc qc::db_qry_parse {qry {level 0} } {
    #| parses a SQL query replacing bind variables
    #| (ACS) like :varname with a quoted version
    #| of $varname in the caller level $level's env
    incr level

    # Quoted fields: Escape colons with \0 and []$\\
    # regsub -all won't work because the regexp need to be applied repeatedly to anchor correctly
    set start 0
    while { $start<[set length [string length $qry]] && [regexp -indices -start $start -- {(^|[^'])'(([^']|'')*)'([^']|$)} $qry -> left field . right] } {
	set qry [string replace $qry [lindex $field 0] [lindex $field 1] [string map {: \\u003A [ \\u005B ] \\u005D $ \\u0024 \\ \\u005C} [string range $qry [lindex $field 0] [lindex $field 1]]]]
        # Calculate how many characters we've added to the string
        set offset [expr [string length $qry]-$length]
        # Offset the start of the next iteration by the increase in string length
	set start [expr [lindex $right 0]+$offset]
    }

    # Dollar Quoted fields
    set start 0
    while { $start<[set length [string length $qry]] \
		&& [regexp -indices -start $start -- {(\$[a-zA-Z0-9_]*?\$)(.*?)(\1)} $qry -> left field right] } {
	set qry [string replace $qry [lindex $left 0] [lindex $right 1] [string map {: \\u003A [ \\u005B ] \\u005D $ \\u0024 \\ \\u005C} [string range $qry [lindex $left 0] [lindex $right 1]]]]
        # Calculate how many characters we've added to the string
        set offset [expr [string length $qry]-$length]
        # Offset the start of the next iteration by the increase in string length
	set start [expr {[lindex $right 1]+1+$offset}]
    }
    
    ## SQL Arrays ##
    # May be multi-dimensional, indexed or slices, with numbers, $variables, :variables, or sql_functions()
    # If sliced with the upper bound being a :variable, \: must be used - eg my_array[2\::index] or my_array[:from_index\::to_index]
    # cannot handle nested sql functions, cannot handle more advanced sql expressions as indices
    set start 0
    while { $start<[string length $qry] \
		&& [regexp -indices -nocase -expanded -start $start -- {[a-z_][a-z0-9_]*(
                                                                                         (?:\[
                                                                                          (?: '?[0-9]+'?
                                                                                           | [:$][a-z_][a-z0-9_]*
                                                                                           | [a-z_]+\([^\)]*\)
                                                                                           )
                                                                                          (?:
                                                                                           :'?[0-9]+'?
                                                                                           | :\$[a-z_][a-z0-9_]*
                                                                                           | \\::[a-z_][a-z0-9_]*
                                                                                           | :[a-z_]+\([^\)]*\)
                                                                                           )?
                                                                                          \])+
                                                                                         )} $qry -> match] } {
	set qry [string replace $qry [lindex $match 0] [lindex $match 1] [string map {\[ \\[ \] \\]} [string range $qry [lindex $match 0] [lindex $match 1]]]]
	set start [expr {[lindex $match 1]+1}]
    }

    # ARRAY constructor - eg. array[1, 2, 3]
    regsub -all -nocase {(array)\[([^\]]+)\]} $qry {\1\\[\2\\]} qry

    # array[]
    set re {
	(
	 bigint
	 |int8
	 |bigserial
	 |serial8
	 |double\s+precision
	 |float8
	 |integer
	 |int
	 |int4
	 |numeric(\([^,]+,[^\)]+\))?
	 |decimal(\([^,]+,[^\)]+\))?
	 |real
	 |float4
	 |smallint
	 |int2
	 |serial
	 |serial4
	 |money

	 |bit(\([^\)]+\))?
	 |bit\s+varying(\([^\)]+\))?
	 |varbit
	 |character\s+varying(\([^\)]+\))?
	 |varchar(\([^\)]+\))?
	 |character(\([^\)]+\))?
	 |char(\([^\)]+\))?
	 |text

	 |date
	 |time(\([^\)]+\))?(\s+with(out)?\s+time\s+zone)?
	 |timetz
	 |timestamp(\([^\)]+\))?(\s+with(out)?\s+time\s+zone)?
	 |timestamptz
	 |interval(\s+[a-z0-9]+)*(\([^\)]+\))?

	 |boolean
	 |bool

	 |bytes
	 |bytea	    
	 |inet
	 |cidr
	 |macaddr
	 |point
	 |line
	 |path
	 |lseg
	 |box	 
	 |circle
	 |polygon	    
	 |tsquery
	 |tsvector
	 |txid_snapshot
	 |uuid
	 |xml	  
	 )\[\]
    }
    regsub -all -nocase -expanded $re $qry {\1\\[\\]} qry

    # Escaped \:colon
    set qry [string map {\\: \0} $qry]
    
    # Colon variable substitution
    set type_re {
	(::(
	    bigint
	    |int8
	    |bigserial
	    |serial8
	    |double\s+precision
	    |float8
	    |integer
	    |int
	    |int4
	    |numeric(\([^,]+,[^\)]+\))?
	    |decimal(\([^,]+,[^\)]+\))?
	    |real
	    |float4
	    |smallint
	    |int2
	    |serial
	    |serial4
	    |money

	    |bit(\([^\)]+\))?
	    |bit\s+varying(\([^\)]+\))?
	    |varbit
	    |character\s+varying(\([^\)]+\))?
	    |varchar(\([^\)]+\))?
	    |character(\([^\)]+\))?
	    |char(\([^\)]+\))?
	    |text

	    |date
	    |time(\([^\)]+\))?(\s+with(out)?\s+time\s+zone)?
	    |timetz
	    |timestamp(\([^\)]+\))?(\s+with(out)?\s+time\s+zone)?
	    |timestamptz
	    |interval(\s+[a-z0-9]+)*(\([^\)]+\))?

	    |boolean
	    |bool

	    |bytes
	    |bytea	    
	    |inet
	    |cidr
	    |macaddr
	    |point
	    |line
	    |path
	    |lseg
	    |box	 
	    |circle
	    |polygon	    
	    |tsquery
	    |tsvector
	    |txid_snapshot
	    |uuid
	    |xml	  
	    )(?=[^a-z0-9]|$)
         )?
    }
    set re {
	([^:\\]):
	([a-z_][a-z0-9_]*)  
    }
    append re $type_re
    regsub -all -nocase -expanded $re $qry {\1[::qc::db_quote [set {\2}] {\4}]} qry

    # Eval with uplevel
    set qry [uplevel $level [list subst $qry]]

    # =NULL to IS NULL
    if {[regexp -nocase {^[ \t\r\n]*select[ \t\r\n]} $qry]} {
	# A select query
        set null_re {=NULL}
        append null_re $type_re
	regsub -all -expanded $null_re $qry { IS NULL} qry
    }
    return $qry
}

proc qc::db_quote { value {type ""}} {
    #| quotes SQL values by escaping single quotes with \'
    #| leaves integers and doubles alone
    #| Empty strings are converted to NULL
    if { $type eq ""} {
	set sql_cast ""
    } else {
	set sql_cast "::$type"
    }

    if { [string equal $value ""] } {
	return "NULL${sql_cast}"
    }
    # Reserved keywords
    if { [in [list current_time current_timestamp] $value ] } {
	return "${value}${sql_cast}"
    }
    
    
    set re_numeric_types {
        ^(
          bigint
          |int8
          |bigserial
          |serial8
          |double\s+precision
          |float8
          |integer
          |int
          |int4
          |numeric(\([^,]+,[^\)]+\))?
          |decimal(\([^,]+,[^\)]+\))?
          |real
          |float4
          |smallint
          |int2
          |serial
          |serial4
          |money
          )$
    }

    if { [regexp -nocase -expanded $re_numeric_types $type] } {
        # integer no leading zeros
        # -123456
        if { [regexp {^-?[1-9][0-9]*$} $value] || [string equal $value 0] } {
            return "${value}${sql_cast}"
        }
        # double greater than 1
        if { [regexp {^-?[1-9][0-9]*\.[0-9]+$} $value] } {
            return "${value}${sql_cast}"
        }
        # decimal less than 1
        # in form .23 or 0.23
        if { [regexp {^(-)?0?\.([0-9]+)$} $value -> sign tail] } {
            return "${sign}0.${tail}${sql_cast}"
        }
        # scientific notation        
        if { [regexp {^-?[1-9][0-9]*(\.[0-9]+)?(e|E)(\+|-)?[0-9]{1,2}$} $value] } {
            return "${value}${sql_cast}"
        }
    } 

    # quote everything as a string
    # replace ' with '' and \ with \\ 
    # (tcl also uses slash to escape hence \\ in string map)
    if { [string first \\ $value]==-1 } {
	return "'[string map {' ''} $value]'${sql_cast}"
    } else {
	return "E'[string map {' '' \\ \\\\} $value]'${sql_cast}"
    }
}

proc qc::db_quote_identifier {value} {
    #| Quote a sql identifier (eg. a table or column name)
    return "\"[string map {\" \"\"} $value]\""
}

proc qc::db_escape_regexp { string } {
    # The postgresql parser performs substitution 
    # before passing the regexp to the regexp engine
    # So to find a match for a regex metacharacter
    # we need to escape the preceding slash.
    # For example "foo." becomes "foo\\."
    set list {
	\\ \\\\ 
	^ \\^ 
	. \\. 
	\[ \\\[ 
	\] \\\] 
	\$ \\\$ 
	\( \\\( 
	\) \\\) 
	| \\| 
	* \\* 
	+ \\+ 
	? \\? 
	\{ \\\{
	\} \\\}
    } 

    return [string map $list $string]
}

proc qc::db_get_handle {{poolname DEFAULT}} {
    # Return db handle 
    # Keep one handle per pool for current thread.
    global _db
    if { [info commands ns_db] eq "ns_db" } {
        # AOL Server
        if { $poolname eq "DEFAULT" } {
	    set poolname [ns_config ns/server/[ns_info server]/db defaultpool]  
	} 
        if { ![info exists _db($poolname)] } {
	    set _db($poolname) [ns_db gethandle $poolname]
	}
        return $_db($poolname)
    } else {
        # Should be connected with db_connect
        if { ![info exists _db] } {
            error "No database connection"
        }
        return $_db
    }
}

proc qc::db_dml { args } {
    args $args -db DEFAULT -- qry
    #| Execute a SQL dml statement
    set db [db_get_handle $db]
    set qry [db_qry_parse $qry 1]
    if { [info commands ns_db] eq "ns_db" } {
        # AOL Server
        ::try {
            ns_db dml $db $qry
        } on error {error_message options} {
            error "Failed to execute dml <code>$qry</code>.<br>[ns_db exception $db]" [dict get $options -errorinfo] [dict get $options -errorcode]
        }
    } else {
        # Connected with db_connect
        ::try {
            pg_execute $db $qry
        } on error {error_message options} {
            error "Failed to execute dml <code>$qry</code>." [dict get $options -errorinfo] [dict get $options -errorcode]
        }
    }
}

proc qc::db_trans {args} {
    #| Execute code within a transaction
    #| Rollback on database or tcl error
    #| Nested db_trans structures do not
    #| emulate postgres nested transactions but simply
    #| ensure code is executed in a transaction by
    #| maintaining a global db_trans_level
    args $args -db DEFAULT -- code {error_code ""}
    global db_trans_level

    if { ![info exists db_trans_level] } {
	set db_trans_level($db) 0
    }
    incr db_trans_level($db)

    set savepoint "db_trans_level_$db_trans_level($db)"

    if { $db_trans_level($db) == 1 } {
	db_dml -db $db "BEGIN WORK"
    } else {
        db_dml -db $db "SAVEPOINT $savepoint"
    }
    
    set return_code [ catch { uplevel 1 $code } result options ]
    switch $return_code {
	1 {
	    # Error
	    if { $db_trans_level($db) > 1 } {
                db_dml -db $db "ROLLBACK TO SAVEPOINT $savepoint"
            } else {
		db_dml -db $db "ROLLBACK WORK"
	    }

	    uplevel 1 $error_code
            # Return in parent stack frame instead of here
            dict incr options -level
	}
	default {
	    # ok, return, break, continue
	    if { $db_trans_level($db) > 1 } {
                db_dml -db $db "RELEASE SAVEPOINT $savepoint"
            } else {
                db_dml "COMMIT WORK"
	    }

            # Preserve TCL_RETURN
            if { $return_code == 2 && [dict get $options -code] == 0 } {
                dict set options -code return
            } else {
                # Return in parent stack frame instead of here
                dict incr options -level
            }
	}
    }
    incr db_trans_level($db) -1
    return -options $options $result
}

proc qc::db_1row { args } {
    # Select 1 row from the database using the qry.
    # Place variables corresponding to column names in the caller's namespace
    # Throw an error if more or less than 1 row is returned.
    args $args -db DEFAULT -- qry
    set table [db_select_table -db $db $qry 1]
    set db_nrows [expr {[llength $table]-1}]
    
    if { $db_nrows!=1 } {
	error "The qry <code>[db_qry_parse $qry 1]</code> returned $db_nrows rows"
    }
    foreach key [lindex $table 0] value [lindex $table 1] { upset 1 $key $value }
    return
}

proc qc::db_0or1row {args} {
    # Select zero or one row from the database using the qry.
    # If zero rows are returned then run no_rows_code else 
    # place variables corresponding to column names in the caller's namespace and execute one_row_body
    args $args -db DEFAULT -- qry {no_rows_code ""} {one_row_code ""}
    set table [db_select_table -db $db $qry 1]
    set db_nrows [expr {[llength $table]-1}]

    if {$db_nrows==0} {
	# no rows
	set return_code [ catch { uplevel 1 $no_rows_code } result options ]
        # Preserve TCL_RETURN
        if { $return_code == 2 && [dict get $options -code] == 0 } {
            dict set options -code return
        } else {
            # Return in parent stack frame instead of here
            dict incr options -level
        }
        return -options $options $result
    } elseif { $db_nrows==1 } { 
	# 1 row
	foreach key [lindex $table 0] value [lindex $table 1] { upset 1 $key $value }
	set return_code [ catch { uplevel 1 $one_row_code } result options ]
        # Preserve TCL_RETURN
        if { $return_code == 2 && [dict get $options -code] == 0 } {
            dict set options -code return
        } else {
            # Return in parent stack frame instead of here
            dict incr options -level
        }
        return -options $options $result
    } else {
	# more than 1 row
	error "The qry <code>[db_qry_parse $qry 1]</code> returned $db_nrows rows"
    }
}

proc qc::db_foreach {args} {
    #| Place variables corresponding to column names in the caller's namespace
    #| for each row returned.
    #| Set special variables db_nrows and db_row_number in caller's namespace to
    #| indicate the number of rows returned and the current row.
    #| Nested foreach statements clean up special variables so they apply to the current scope.
    args $args -db DEFAULT -- qry foreach_code { no_rows_code ""}

    # save special db variables
    qc::upcopy 1 db_nrows      saved_db_nrows
    qc::upcopy 1 db_row_number saved_db_row_number

    set table [db_select_table -db $db $qry 1] 
    set db_nrows [expr {[llength $table]-1}]
    set db_row_number 0

    if { $db_nrows == 0 } {
	upset 1 db_nrows 0
	upset 1 db_row_number 0
	set return_code [ catch { uplevel 1 $no_rows_code } result options ]
        switch $return_code {
            0 {
                # ok
            }
            default {
                # error, return
                
                # Preserve TCL_RETURN
                if { $return_code == 2 && [dict get $options -code] == 0 } {
                    dict set options -code return
                } else {
                    # Return in parent stack frame instead of here
                    dict incr options -level
                }
                return -options $options $result
            }
        }
    } else {
	set masterkey [lindex $table 0]
	foreach list [lrange $table 1 end] {
	    upset 1 db_nrows $db_nrows
	    upset 1 db_row_number [incr db_row_number]
	    foreach key $masterkey value $list {
		upset 1 $key $value
	    }
	    set return_code [ catch { uplevel 1 $foreach_code } result options ]
            switch $return_code {
                0 {
                    # ok
                }
                3 -
                4 {
                    # break, continue
                    return -options $options $result
                }
                default {
                    # error, return

                    # Preserve TCL_RETURN
                    if { $return_code == 2 && [dict get $options -code] == 0 } {
                        dict set options -code return
                    } else {
                        # Return in parent stack frame instead of here
                        dict incr options -level
                    }
                    return -options $options $result
                }
            }

            # Clean up the result variable to prevent Tcl's Copy on Write
            # process from adversely affecting performance
            unset result
        }
    }
    # restore saved variables
    if { [info exists saved_db_nrows] } {
	upset 1 db_nrows      $saved_db_nrows
	upset 1 db_row_number $saved_db_row_number
    }
}

proc qc::db_seq {args} {
    args $args -db DEFAULT -- seq_name
    # Fetch the next value from the sequence named seq_name
    set qry "select nextval(:seq_name) as next_id"
    db_1row -db $db $qry
    return $next_id
}

proc qc::db_select_table {args} {
    # Select results of qry into a table
    # Parse qry at level given
    args $args -db DEFAULT -- qry {level 0}
    incr level
    set qry [db_qry_parse $qry $level]
    set table {}
    set db [db_get_handle $db]
    if { [info commands ns_db] eq "ns_db" } {
        # AOL Server
        qc::try {
            set row [ns_db select $db $qry]
            lappend table [ns_set_keys $row]
            while { [ns_db getrow $db $row] } {
                lappend table [ns_set_values $row]
            }
            return $table
        } {
            error "Failed to execute qry <code>$qry</code><br>[ns_db exception $db]"
        }
    } else {
        # Connected with db_connect
        ::try {
            set results [pg_exec $db $qry]
            lappend table [pg_result $results -attributes]
            set table [concat $table [pg_result $results -llist]]
            pg_result $results -clear
            return $table
        } on error {error_message options} {
	    error "Failed to execute qry <code>$qry</code><br>" [dict get $options -errorinfo] [dict get $options -errorcode]
        }
    }
}

proc qc::db_select_csv { qry {level 0} } {
    #| Select qry into csv report
    #| First row contains column names
    incr level
    set table [db_select_table $qry $level]
    foreach row $table {
        lappend lines [list2csv $row]
    }
    return [join $lines \r\n]
}

proc qc::db_select_ldict { qry } {
    # Select the results of qry into a ldict
    set table [db_select_table $qry 1]
    return [qc::table2ldict $table]
}

proc qc::db_select_dict { qry } {
    # Select 0 or 1 row from the database using the qry.
    # Place result in a dict
    # Throw an error if more than 1 row is returned.

    set table [db_select_table $qry 1]
    set db_nrows [expr {[llength $table]-1}]
    
    if { $db_nrows>1 } {
	error "The qry <code>[db_qry_parse $qry 1]</code> returned $db_nrows rows"
    }
    set dict {}
    foreach key [lindex $table 0] value [lindex $table 1] { lappend dict $key $value }
    return $dict
}

proc qc::db_row_exists {table args} {
    #| Check for existance of 1 or more rows in $table
    #| Matching name/value pairs in $args
    set dict [qc::args2dict $args]
    db_0or1row {
        select true as exists
        from [db_quote_identifier $table]
        where [sql_where {*}$dict]
        limit 1
    } {
        return false
    } {
        return true
    }
}

proc qc::db_connect {args} {
    #| Connect to a postgresql database
    global _db
    ::try {
        package require Pgtcl 1.5
        set _db [pg_connect -connlist $args]
    } on error {error_message options} {
        error "Could not connect to database. $error_message" [dict get $options -errorinfo] [dict get $options -errorcode]
    }
}