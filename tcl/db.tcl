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
        if { ![info exists _db($poolname)] } {
            if { [string equal $poolname DEFAULT] } {
                set _db($poolname) [ns_db gethandle]
            } else {
                set _db($poolname) [ns_db gethandle $poolname]
            }
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
        qc::try {
            ns_db dml $db $qry
        } {
            global errorInfo
            error "Failed to execute dml <code>$qry</code>.<br>[ns_db exception $db]" $errorInfo
        }
    } else {
        # Connected with db_connect
        qc::try {
            pg_execute $db $qry
        } {
            global errorInfo
            error "Failed to execute dml <code>$qry</code>.<br>" $errorInfo
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
    global db_trans_level errorInfo errorCode
    if { ![info exists db_trans_level] } {
	set db_trans_level($db) 0
    }
    
    if { $db_trans_level($db) == 0 } {
	db_dml -db $db "BEGIN WORK"
	incr db_trans_level($db)
    } else {
	incr db_trans_level($db)
    }
    set code [ catch { uplevel 1 $code } result ]
    switch $code {
	1 {
	    # Error
	    if { $db_trans_level($db) >= 1 } {
		db_dml "ROLLBACK WORK"
		set db_trans_level($db) 0
	    }
	    uplevel 1 $error_code
	    return -code error -errorcode $errorCode -errorinfo $errorInfo $result 
	}
	default {
	    # normal,return,break,continue
	    if { $db_trans_level($db) == 1 } {
		db_dml "COMMIT WORK"
		set db_trans_level($db) 0
	    } else {
		incr db_trans_level($db) -1
	    }
	    return -code $code $result
	}
    }
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
	set code [ catch { uplevel 1 $no_rows_code } result ]
	switch $code {
	    1 { 
		global errorCode errorInfo
		return -code error -errorcode $errorCode -errorinfo $errorInfo $result 
	    }
	    default {
		return -code $code $result
	    }
	}
    } elseif { $db_nrows==1 } { 
	# 1 row
	foreach key [lindex $table 0] value [lindex $table 1] { upset 1 $key $value }
	set code [ catch { uplevel 1 $one_row_code } result ]
	switch $code {
	    1 { 
		global errorCode errorInfo
		return -code error -errorcode $errorCode -errorinfo $errorInfo $result 
	    }
	    default {
		return -code $code $result
	    }
	}
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
    global errorCode errorInfo

     # save special db variables
    qc::upcopy 1 db_nrows      saved_db_nrows
    qc::upcopy 1 db_row_number saved_db_row_number

    set table [db_select_table -db $db $qry 1] 
    set db_nrows [expr {[llength $table]-1}]
    set db_row_number 0

    if { $db_nrows == 0 } {
	upset 1 db_nrows 0
	upset 1 db_row_number 0
	set returnCode [ catch { uplevel 1 $no_rows_code } result ]
	switch $returnCode {
	    0 {
		# normal
	    }
	    1 { 
		return -code error -errorcode $errorCode -errorinfo $errorInfo $result 
	    }
	    default {
		return -code $returnCode $result
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
	    set returnCode [ catch { uplevel 1 $foreach_code } result ]
	    switch $returnCode {
		0 {
		    # Normal
		}
		1 { 
		    return -code error -errorcode $errorCode -errorinfo $errorInfo $result 
		}
		2 {
		    return -code return $result
		}
		3 {
		    break
		}
		4 {
		    continue
		}
	    }
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
        qc::try {
            set results [pg_exec $db $qry]
            lappend table [pg_result $results -attributes]
            set table [concat $table [pg_result $results -llist]]
            pg_result $results -clear
            return $table
        } {
            global errorInfo
            error "Failed to execute qry <code>$qry</code><br>" $errorInfo
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

proc qc::db_col_varchar_length { table_name col_name } {
    #| Returns the varchar length of a db table column
    set qry "
        SELECT
                a.atttypmod-4 AS lengthvar,
                t.typname AS type
        FROM
                pg_attribute a,
                pg_class c,
                pg_type t
        WHERE
                c.relname = :table_name
                and a.attnum > 0
                and a.attrelid = c.oid
                and a.atttypid = t.oid
                and a.attname = :col_name
        ORDER BY a.attnum
    "
    db_0or1row $qry {
    error "No such column \"$col_name\" in table \"$table_name\""
    } 
    if { [eq $type varchar] } {
        return $lengthvar
    } else {
    error "Col \"$col_name\" is not type varchar it is type \"$type\""
    }
}

proc qc::db_connect {args} {
    #| Connect to a postgresql database
    global _db
    qc::try {
        package require Pgtcl 1.5
        set _db [pg_connect -connlist $args]
    } {
        global errorInfo errorMessage
        error "Could not connect to database. $errorMessage" $errorInfo
    }
}

proc qc::db_column_exists {column} {
    #| Checks if the given column name exists in the database.
    set qry {
        SELECT column_name
        FROM information_schema.columns
        WHERE column_name=:column
    }
    set columns [qc::db_select_ldict $qry]
    if {[llength $columns] > 0} {
        return true
    } else {
        return false
    }
}

proc qc::db_table_columns {table} {
    #| Returns a list of columns for the given table.
    set qry {
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name=:table
        ORDER BY ordinal_position;
    }
    set columns {}
    qc::db_foreach $qry {
        lappend columns $column_name
    }
    return $columns
}

proc qc::db_table_column_exists {table column} {
    #| Checks if the column exists in the given table.
    set qry {
        SELECT column_name
        FROM information_schema.columns
        WHERE column_name=:column
        AND table_name=:table;
    }
    qc::db_0or1row $qry {
        return false
    } {
        return true
    }
}

proc qc::db_column_table {column} {
    #| Returns a list of tables that the given column name is part of.
    set qry {
        SELECT table_name
        FROM information_schema.columns
        WHERE column_name=:column
    }
    set tables {}
    qc::db_foreach $qry {
        lappend tables $table_name
    }
    return $tables
}

proc qc::db_qualified_table_column {column} {
    #| Returns a fully qualified table column as a list of a pair: {table column}
    if {[qc::db_column_exists $column]} {
        set tables [qc::db_column_table $column]
        if {[llength $tables] > 1 && [qc::db_column_table_primary_exists $column]} {
            # try a column that's a also primary key
            set table [qc::db_column_table_primary $column]
        } else {
            # try the first table anyway
            set table [lindex $tables 0]
        }
        return [list $table $column]
    } else {
        return -code error "\"$column\" doesn't exist as a column in the database."
    }
}

proc qc::db_column_table_primary_exists {column} {
    #| Checks whether the given column exists as a primary key in the database.
    ::try {
        qc::db_column_table_primary $column
        return true
    } on error [list error_message options] {
        return false
    }
}

proc qc::db_column_table_primary {column} {
    #| Returns a table that the given column is a primary key in.
    set qry {
        SELECT tc.table_name
        FROM information_schema.columns cols
        JOIN information_schema.table_constraints tc
        ON cols.table_name=tc.table_name
        WHERE column_name=:column
        AND constraint_type='PRIMARY KEY'
        LIMIT 1;
    }
    qc::db_1row $qry
    return $table_name
}

proc qc::db_column_type {table column} {
    #| Returns the data type of the column in the given table.
    set qry {
        SELECT column_name, coalesce(domain_name, udt_name) as data_type, character_maximum_length, numeric_precision, numeric_scale
        FROM information_schema.columns
        WHERE table_name=:table and column_name=:column
    }
    qc::db_0or1row $qry {
         return -code error -errorcode DB_COLUMN "Column \"$column\" does not exist for table \"$table\"."
    } {
        return [qc::db_canonical_type $data_type $character_maximum_length $numeric_precision $numeric_scale]
    }
}

proc qc::db_table_column_types {table} {
    #| Returns a dict of all columns and their types in the given table.
    set qry {
        SELECT column_name, coalesce(domain_name, udt_name) as data_type, character_maximum_length, numeric_precision, numeric_scale
        FROM information_schema.columns
        WHERE table_name=:table
        ORDER BY ordinal_position;
    }
    set column_types {}
    qc::db_foreach $qry {
        lappend column_types $column_name [qc::db_canonical_type $data_type $character_maximum_length $numeric_precision $numeric_scale]
    }
    return $column_types
}

proc qc::db_column_nullable {table column} {
    #| Checks if the column in the given table can hold null values.
    set qry {
        SELECT is_nullable
        FROM information_schema.columns
        WHERE table_name=:table
        AND column_name=:column
    }
    qc::db_1row $qry
    if {$is_nullable} {
        return true
    } else {
        return false
    }
}

proc qc::db_enum_values {enum_name} {
    #| Returns a list of the values for the given enumeration
    set qry {
        SELECT e.enumlabel as value
        FROM pg_enum e 
        JOIN pg_type t
        ON t.oid = e.enumtypid
        WHERE t.typname=:enum_name;
    }
    set values {}
    qc::db_foreach $qry {
        lappend values $value
    }
    return $values
}

proc qc::db_enum_exists {enum_name} {
    #| Checks if the given enum exists in the database.
    set qry {
        SELECT e.enumtypid
        FROM pg_enum e
        JOIN pg_type t
        ON t.oid = e.enumtypid
        WHERE t.typname=:enum_name
        LIMIT 1;
    }
    qc::db_0or1row $qry {
        return false
    } {
        return true
    }
}

proc qc::db_domain_exists {domain_name} {
    #| Checks if the given domain exists in the database.
    set qry {
        SELECT domain_name
        FROM information_schema.domains
        WHERE domain_name=:domain_name;
    }
    qc::db_0or1row $qry {
        return false
    } {
        return true
    }
}

proc qc::db_domain_constraint {domain_name} {
    #| Returns a dict of the constraint name with the check clause for the given domain in the database.
    if {[qc::db_domain_exists $domain_name]} {
        set qry {
            SELECT cc.constraint_name, check_clause
            FROM information_schema.check_constraints cc
            JOIN information_schema.domain_constraints dc
            ON dc.constraint_name=cc.constraint_name
            WHERE dc.domain_name=:domain_name;
        }
        qc::db_1row $qry
        return [list $constraint_name $check_clause]
    } else {
        return -code error -errorcode DB_DOMAIN "Domain \"$domain_name\" does not exist."
    }
}

proc qc::db_column_constraints {table column} {
    #| Returns a dict of constraint name and check clause for the given column
    if {[qc::db_table_column_exists $table $column]} {
        set qry {
            SELECT cc.constraint_name, check_clause
            FROM information_schema.check_constraints cc
            JOIN information_schema.constraint_column_usage ccu
            ON cc.constraint_name=ccu.constraint_name
            WHERE ccu.table_name=:table
            AND ccu.column_name=:column;
        }
        set constraints {}
        qc::db_foreach $qry {
            lappend constraints $constraint_name $check_clause
        }
        return $constraints
    } else {
        return -code error -errorcode DB_COLUMN "Column \"$table.$column\" does not exist."
    }
}

proc qc::db_eval_constraint {table constraint args} {
    #| Check a db constraint expression by substituting in corresponding values from args
    # eg constraint_test {(col1 > col2)} col1 17 col2 16
    set column_types [qc::db_table_column_types $table]
    set columns [dict keys $column_types]
    set column_values [qc::dict_subset $args {*}$columns]
    set list {}
    foreach {column value} $column_values {
        lappend list "[qc::db_quote $value]::[dict get $column_types $column] as $column"
    }    
    set sub_select "SELECT [join $list ,]"

    set qry {
        SELECT $constraint AS result
        FROM ($sub_select) alias;
    }

    qc::db_1row $qry
    return $result
}

proc qc::db_eval_domain_constraint {domain_name value} {
    #| Evaluates the domain constraint against the given value.
    lassign [qc::db_domain_constraint $domain_name] constraint_name check_clause
    set qry {
        SELECT $check_clause AS result
        FROM (SELECT :value::$domain_name as VALUE) alias;
    }
    ::try {
        qc::db_1row $qry
        return $result
    } on error [list error_message options] {
        return f
    }
}

proc qc::db_eval_column_constraints {table column values} {
    #| Evaluates constraints on the given table.column with the given values.
    #| Returns a dict of the constraints and their results.
    set constraints [qc::db_column_constraints $table $column]
    set results {}
    foreach {constraint_name check_clause} $constraints {
        lappend results $constraint_name [qc::db_eval_constraint $table $check_clause {*}$values]
    }
    return $results
}

proc qc::db_domain_base_type {domain_name} {
    #| Returns the base type of the given domain.
    if {[qc::db_domain_exists $domain_name]} {
        set qry {
            SELECT udt_name, character_maximum_length, numeric_precision, numeric_scale
            FROM information_schema.domains
            WHERE domain_name=:domain_name;
        }
        qc::db_1row $qry
        return [qc::db_canonical_type $udt_name $character_maximum_length $numeric_precision $numeric_scale]
    } else {
        return -code error -errorcode DB_DOMAIN "Domain \"$domain_name\" does not exist."
    }
}

proc qc::db_canonical_type {udt_name {character_maximum_length ""} {numeric_precision ""} {numeric_scale ""}} {
    #| Returns the canonical type name for the given type name.
    switch -glob -- $udt_name {
        varchar {
            return [expr {$character_maximum_length ne "" ? "varchar($character_maximum_length)": "varchar"}]
        }
        numeric {
            return [expr {$numeric_precision ne "" ? "decimal($numeric_precision,$numeric_scale)": "decimal"}]
        }
        bpchar {
            return "char($character_maximum_length)"
        }
        bit {
            return "bit($character_maximum_length)"
        }
        default {
            return $udt_name
        }
    }
}

proc qc::db_validation_message {table column} {
    #| Returns the validation message associated with the given table.column
    set qry {
        SELECT message
        FROM validation_messages
        WHERE table_name=:table
        AND column_name=:column;
    }
    qc::db_0or1row $qry {
        qc::db_0or1row {
            SELECT message
            FROM validation_messages
            WHERE column_name=:column
            LIMIT 1;
        } {
            set message "Invalid $column."
        }
    }
    return $message
}
