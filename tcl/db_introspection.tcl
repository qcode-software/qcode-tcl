namespace eval qc {
    namespace export db_*
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
    db_cache_0or1row -ttl 86400 $qry {
    error "No such column \"$col_name\" in table \"$table_name\""
    } 
    if { [eq $type varchar] } {
        return $lengthvar
    } else {
    error "Col \"$col_name\" is not type varchar it is type \"$type\""
    }
}

proc qc::db_column_exists {column} {
    #| Checks if the given column name exists in the database.
    db_cache_1row -ttl 86400 {
        SELECT count(*) as count 
        FROM information_schema.columns
        WHERE column_name=:column
    }
    if {$count > 0} {
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
    qc::db_cache_foreach -ttl 86400 $qry {
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
    qc::db_cache_0or1row -ttl 86400 $qry {
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
    qc::db_cache_foreach -ttl 86400 $qry {
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
        FROM information_schema.table_constraints tc
        JOIN information_schema.constraint_column_usage ccu
        USING (table_name, constraint_name)
        WHERE column_name=:column
        AND constraint_type='PRIMARY KEY'
        LIMIT 1;
    }
    qc::db_cache_1row -ttl 86400 $qry
    return $table_name
}

proc qc::db_column_type {table column} {
    #| Returns the data type of the column in the given table.
    set qry {
        SELECT column_name, coalesce(domain_name, udt_name) as data_type, character_maximum_length, numeric_precision, numeric_scale
        FROM information_schema.columns
        WHERE table_name=:table and column_name=:column
    }
    qc::db_cache_0or1row -ttl 86400 $qry {
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
    qc::db_cache_foreach -ttl 86400 $qry {
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
    qc::db_cache_1row -ttl 86400 $qry
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
    qc::db_cache_foreach -ttl 86400 $qry {
        lappend values $value
    }
    return $values
}

proc qc::db_enum_exists {args} {
    #| Checks if the given enum exists in the database.
    qc::args $args -no-cache -- enum_name
    set qry {
        select e.enumtypid
        from pg_enum e
        join pg_type t on t.oid = e.enumtypid
        join pg_namespace n on n.oid = t.typnamespace
        where t.typname=:enum_name
        and n.nspname in (
                          select *
                          from unnest(current_schemas(true))
                          )
        limit 1;
    }
    if { [info exists no-cache] } {
	set ttl -1
    } else {
	set ttl 86400
    }
    qc::db_cache_0or1row -ttl $ttl $qry {
        return false
    } {
        return true
    }
}

proc qc::db_domain_exists {args} {
    #|Checks if the given domain exists in the database
    qc::args $args -no-cache -- domain_name
    set qry {
	SELECT domain_name
	FROM information_schema.domains
	WHERE domain_name=:domain_name;
    }
    if { [info exists no-cache] } {
	set ttl -1
    } else {
	set ttl 86400
    }
    qc::db_cache_0or1row -ttl $ttl $qry {
	return false
    } {
	return true
    }
}

proc qc::db_domain_constraints {domain_name} {
    #| Returns a dict of the constraint name with the check clause for the given domain in the database.
    set constraints [dict create]
    if {[qc::memoize qc::db_domain_exists $domain_name]} {
        set qry {
            SELECT cc.constraint_name, check_clause
            FROM information_schema.check_constraints cc
            JOIN information_schema.domain_constraints dc
            ON dc.constraint_name=cc.constraint_name
            WHERE dc.domain_name=:domain_name;
        }
        qc::db_cache_foreach -ttl 86400 $qry {
            dict set constraints $constraint_name $check_clause
        }
        return $constraints
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
        qc::db_cache_foreach -ttl 86400 $qry {
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
    set column_types [qc::memoize qc::db_table_column_types $table]
    set columns [dict keys $column_types]
    set fq_columns [qc::map [list x "return $table.\$x"] $columns]
    set column_values [qc::dict_subset $args {*}$columns {*}$fq_columns]
    set list {}
    foreach {name value} $column_values {
        if { ![regexp {^([^\.]+)\.([^\.]+)$} $name -> table column] } {
            set column $name
        }
            
        lappend list "[qc::db_quote $value]::[dict get $column_types $column] as $column"
    }    
    set sub_select "SELECT [join $list ,]"

    set qry {
        SELECT coalesce($constraint, true) AS result
        FROM ($sub_select) alias;
    }

    qc::db_cache_1row -ttl 86400 $qry
    return $result
}

proc qc::db_eval_domain_constraint {value base_type check_clause} {
    #| Evaluates the domain constraint against the given value.
    set qry {
        SELECT $check_clause AS result
        FROM (SELECT :value::$base_type as VALUE) alias;
    }
    ::try {
        qc::db_cache_1row -ttl 86400 $qry
        return $result
    } on error [list error_message options] {
        return f
    }
}

proc qc::db_eval_column_constraints {table column values} {
    #| Evaluates constraints on the given table.column with the given values.
    #| Returns a dict of the constraints and their results.
    set constraints [qc::memoize qc::db_column_constraints $table $column]
    set results {}
    foreach {constraint_name check_clause} $constraints {
        lappend results $constraint_name [qc::db_eval_constraint $table $check_clause {*}$values]
    }
    return $results
}

proc qc::db_domain_base_type {domain_name} {
    #| Returns the base type of the given domain.
    if {[qc::memoize qc::db_domain_exists $domain_name]} {
        set qry {
            SELECT udt_name, character_maximum_length, numeric_precision, numeric_scale
            FROM information_schema.domains
            WHERE domain_name=:domain_name;
        }
        qc::db_cache_1row -ttl 86400 $qry
        return [qc::db_canonical_type $udt_name $character_maximum_length $numeric_precision $numeric_scale]
    } else {
        return -code error -errorcode DB_DOMAIN "Domain \"$domain_name\" does not exist."
    }
}

proc qc::db_canonical_type {udt_name {character_maximum_length ""} {numeric_precision ""} {numeric_scale ""}} {
    #| Returns the canonical type name for the given type name.
    switch -glob -- $udt_name {
        varchar {
            return [expr {$character_maximum_length ne "" ? "varchar($character_maximum_length)": "text"}]
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
        WHERE
        column_name=:column
        order by table_name=:table DESC
        LIMIT 1
    }
    qc::db_cache_0or1row -ttl 86400 $qry {
        set message "Invalid $column."
    }
    return $message
}

proc qc::db_sequence_exists {args} {
    #| Checks if the given sequence exists in the database
    qc::args $args -no-cache -- sequence_name
    set qry {
	SELECT sequence_name 
	FROM information_schema.sequences
	WHERE sequence_name=:sequence_name;
    }
    if { [info exists no-cache] } {
	set ttl -1
    } else {
	set ttl 86400
    }
    qc::db_cache_0or1row -ttl $ttl $qry {
	return false
    } {
	return true
    }
}

proc qc::db_owner {database_name} {
    #| Gets the owner of the database
    set qry {
	SELECT u.usename as database_owner
	FROM pg_database d
	JOIN pg_user u ON (d.datdba=u.usesysid)
	WHERE d.datname=:database_name
    }
    db_0or1row $qry {
	error "Database \"$database_name\" does not exists"
    } {
	return $database_owner
    }
}

proc qc::db_database_name {{poolname DEFAULT}} {
    #| Gets the name of the database using poolname
    set qry {
	select current_database() as current_database
    }
    db_1row -db $poolname $qry
    return $current_database
}

proc qc::db_user {{poolname DEFAULT}} {
    #| Gets the user configured to connect to database using poolname
    return [ns_db user [db_get_handle $poolname]]
}

proc qc::db_extension_exists {extension_name} {
    #| Checks if the extension exists in database
    set qry {
	SELECT extname
	FROM pg_extension
	WHERE extname=:extension_name
    }
    db_0or1row $qry {
	return false
    } {
	return true
    }

}

proc qc::db_user_is_superuser {username} {
    #| Returns true if username specified is a superuser
    set qry {
	SELECT usesuper
	FROM pg_user
	WHERE usename=:username;
    } 
    db_0or1row $qry {  
	# user does not exist
	error "Database user \"$username\" does not exist." 
    } {
	return $usesuper
    }
}

proc qc::db_is {data_type value} {
    #| Determines if the value is a database data type.
    set qry {
        SELECT :value::$data_type as VALUE;
    }
    
    ::try {
        qc::db_cache_1row -ttl 86400 $qry
        return t
    } on error [list error_message options] {
        return f
    }
}
