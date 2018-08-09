namespace eval qc {
    namespace export db_*
}

proc qc::db_qualify_column {args} {
    #| Attempt to resolve 1-3 args as schema, table, column
    # Assume args are one of:
    # column
    # table column
    # schema table column
    switch [llength $args] {
        1 {
            lassign $args column_name

            # Select whichever table(s) in the current search path contain
            # column, and are earliest in schema search path
            set data [list]
            db_cache_foreach -ttl 86400 {
                select *
                from (
                      select
                      table_schema,
                      index,
                      table_name,
                      min(index) over () as min_index

                      from information_schema.columns
                      join (
                            select distinct on(table_name)
                            table_name,
                            table_schema,
                            index

                            from information_schema.tables
                            cross join
                            generate_series(1,
                                            array_length(current_schemas(true),1)
                                            ) as index

                            where table_schema = (current_schemas(true))\[index\]

                            order by
                            table_name,
                            index
                            ) i using(table_schema,table_name)
                      
                      where column_name = :column_name
                      ) t
                where index=min_index
            } {
                lappend data [dict_from {*}{
                    table_schema
                    table_name
                }]
            }

            # No tables in search path, check for all tables containing column
            if { [llength $data] == 0 } {
                db_cache_foreach -ttl 86400 {
                    select
                    table_schema,
                    table_name
                    
                    from information_schema.columns

                    where column_name = :column_name
                } {
                    lappend data [dict_from {*}{
                        table_schema
                        table_name
                    }]
                }
            }

            # Still no tables found
            if { [llength $data] == 0 } {
                error "No table containing column \"$column\""
            }

            # Exactly one table found
            if { [llength $data] == 1 } {
                dict2vars [lindex $data 0] table_schema table_name
                return [list $table_schema $table_name $column_name]
            }
            
            # Filter selected tables for one where column is a primary key
            set sql_value_rows [list]
            foreach row $data {
                dict2vars $row table_schema table_name
                lappend sql_value_rows \
                    "([db_quote $table_schema], [db_quote $table_name])"
            }
            db_cache_0or1row -ttl 86400 {
                select
                table_schema,
                table_name

                from (VALUES [join $sql_value_rows ,])
                as t (table_schema, table_name)
                
                join information_schema.table_constraints tc
                using (table_schema, table_name)

                join information_schema.constraint_column_usage ccu
                using (table_schema, table_name, constraint_name)

                where column_name=:column_name
                and constraint_type='PRIMARY KEY'

                limit 1
            } {
                # No tables with column as a primary key;
                # just return the first table found
                dict2vars [lindex $data 0] table_schema table_name                
            }
            return [list $table_schema $table_name $column_name]
        }
        2 {
            lassign $args table_name column_name

            # Look for a table in the current search path matching
            # table name
            db_cache_0or1row -ttl 86400 {
                select table_schema
                from information_schema.tables
                cross join generate_series(1,
                                           array_length(current_schemas(true),1)
                                           ) as index
                where table_schema = (current_schemas(true))\[index\]
                and table_name = :table_name
                order by index
                limit 1
            } {
                # No table found in search path;
                # fall back to any table containing column
                db_cache_1row -ttl 86400 {
                    select table_schema
                    from information_schema.columns
                    where table_name=:table_name
                    and column_name=:column_name
                    limit 1
                }
            } {
                # Check that selected table contains column
                db_cache_0or1row -ttl 86400 {
                    select true as exists
                    from information_schema.columns
                    where table_name=:table_name
                    and table_schema=:table_schema
                    and column_name=:column_name
                } {
                    error "Column \"$column_name\" not found in table \"$table_name\""
                }
            }
        }
        3 { lassign $args table_schema table_name column_name }
        default {
            error "Unable to resolve args to db_qualify_column"
        }
    }
    return [list $table_schema $table_name $column_name]
}

proc qc::db_resolve_field_name {name} {
    #| Resolve a field name to schema, table, column
    set parts [split $name "."]
    return [qc::db_qualify_column {*}$parts]
}

proc qc::db_qualify_table {args} {
    #| Resolve args to schema and table
    switch [llength $args] {
        1 {
            lassign $args table_name

            # Look for first table in search path matching table_name
            db_cache_0or1row -ttl 86400 {
                select table_schema

                from information_schema.tables
                cross join generate_series(1,
                                           array_length(current_schemas(true),1)
                                           ) as index

                where table_schema = (current_schemas(true))\[index\]
                and table_name = :table_name

                order by index
                
                limit 1
            } {
                # Fall back to any table matching table_name
                db_cache_1row -ttl 86400 {
                    select table_schema
                    from information_schema.tables
                    where table_name = :table_name
                    limit 1
                }
            }
        }
        2 {
            lassign $args table_schema table_name
        }
        default {
            error "Unable to resolve args to db_qualify_table"
        }
    }
    return [list $table_schema $table_name]
}

proc qc::db_col_varchar_length {args} {
    #| Returns the varchar length of a db table column
    lassign [qc::db_qualify_column {*}$args] {*}{
        schema
        table
        column
    }
    set qry {
        SELECT
        a.atttypmod-4 AS lengthvar,
        t.typname AS type

        FROM
        pg_namespace n,
        pg_attribute a,
        pg_class c,
        pg_type t

        WHERE
        n.nspname = :schema
        and c.relnamespace = n.oid
        and c.relname = :table
        and a.attnum > 0
        and a.attrelid = c.oid
        and a.atttypid = t.oid
        and a.attname = :column

        ORDER BY a.attnum
    }
    db_cache_0or1row -ttl 86400 $qry {
        error "No such column \"$column\" in table \"${schema}.${table}\""
    } 
    if { [eq $type varchar] } {
        return $lengthvar
    } else {
        error "Col \"$column\" is not type varchar it is type \"$type\""
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

proc qc::db_table_columns {args} {
    #| Returns a list of columns for the given table.
    lassign [qc::db_qualify_table {*}$args] {*}{
        table_schema
        table_name
    }
    set qry {
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name=:table
        AND table_schema=:table_schema
        ORDER BY ordinal_position;
    }
    set columns {}
    qc::db_cache_foreach -ttl 86400 $qry {
        lappend columns $column_name
    }
    return $columns
}

proc qc::db_table_column_exists {args} {
    #| Checks if the column exists in the given table.
    lassign [qc::db_qualify_table {*}[lrange $args 0 end-1]] {*}{
        table_schema
        table_name
    }
    set column [lindex $args end]
    set qry {
        SELECT column_name
        FROM information_schema.columns
        WHERE column_name=:column
        AND table_name=:table_name
        AND table_schema=:table_schema;
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
    # No multi-schema support; use qc::db_qualify_column instead
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

proc qc::db_column_type {args} {
    #| Returns the data type of the column in the given table.
    qc::args $args -qualified -- args
    default qualified false
    lassign [qc::db_qualify_column {*}$args] {*}{
        table_schema
        table_name
        column_name
    }
    set qry {
        SELECT
        column_name,
        domain_name,
        domain_schema,
        udt_name,
        udt_schema,
        character_maximum_length,
        numeric_precision,
        numeric_scale

        FROM information_schema.columns

        WHERE table_schema=:table_schema
        and table_name=:table_name
        and column_name=:column_name
    }
    qc::db_cache_0or1row -ttl 86400 $qry {
        return -code error -errorcode DB_COLUMN "Column \"$column\" does not exist for table \"$table\"."
    } {
        if { $qualified } {
            if { $domain_name ne "" } {
                set data_type "${domain_schema}.${domain_name}"
            } elseif { $udt_schema ne "pg_catalog" } {
                set data_type "${udt_schema}.${udt_name}"
            } else {
                set data_type $udt_name
            }
        } else {
            if { $domain_name ne "" } {
                set data_type $domain_name
            } else {
                set data_type $udt_name
            }
        }
        return [qc::db_canonical_type $data_type $character_maximum_length $numeric_precision $numeric_scale]
    }
}

proc qc::db_table_column_types {args} {
    #| Returns a dict of all columns and their types in the given table.
    qc::args $args -qualified -- args
    default qualified false
    lassign [qc::db_qualify_table {*}$args] {*}{
        table_schema
        table_name
    }
    set qry {
        SELECT column_name,
        character_maximum_length,
        domain_name,
        domain_schema,
        udt_name,
        udt_schema,
        numeric_precision,
        numeric_scale

        FROM information_schema.columns

        WHERE table_schema=:table_schema
        and table_name=:table_name

        ORDER BY ordinal_position;
    }
    set column_types {}
    qc::db_cache_foreach -ttl 86400 $qry {
        if { $qualified } {
            if { $domain_name ne "" } {
                set data_type "${domain_schema}.${domain_name}"
            } elseif { $udt_schema ne "pg_catalog" } {
                set data_type "${udt_schema}.${udt_name}"
            } else {
                set data_type $udt_name
            }
        } else {
            if { $domain_name ne "" } {
                set data_type $domain_name
            } else {
                set data_type $udt_name
            }
        }
        lappend column_types $column_name [qc::db_canonical_type $data_type $character_maximum_length $numeric_precision $numeric_scale]
    }
    return $column_types
}

proc qc::db_column_nullable {args} {
    #| Checks if the column in the given table can hold null values.
    lassign [qc::db_qualify_column {*}$args] {*}{
        table_schema
        table_name
        column_name
    }
    set qry {
        SELECT is_nullable
        FROM information_schema.columns
        WHERE table_schema=:table_schema
        and table_name=:table_name
        and column_name=:column_name
    }
    qc::db_cache_1row -ttl 86400 $qry
    if {$is_nullable} {
        return true
    } else {
        return false
    }
}

proc qc::db_resolve_type_name {name} {
    #| Attempt to resolve args to schema and type_name
    set parts [split $name "."]
    switch [llength $parts] {
        2 { return $parts }
        1 {
            set type_name [lindex $parts 0]
            db_cache_0or1row -ttl 86400 {
                select
                n.nspname as schema

                from
                pg_namespace n,
                pg_type t,
                generate_series(1,
                                array_length(current_schemas(true),1)
                                ) as index

                where t.typnamespace = n.oid
                and t.typname = :type_name
                and n.nspname = (current_schemas(true))\[index\]

                order by index

                limit 1
            } {
                db_cache_1row -ttl 86400 {
                    select
                    n.nspname as schema

                    from
                    pg_namespace n,
                    pg_type t

                    where t.typnamespace = n.oid
                    and t.typname = :type_name

                    limit 1
                }
            }
            return [list $schema $type_name]
        }
        default {
            error "Unable to resolve type name \"$name\""
        }
    }
}

proc qc::db_enum_values {enum_name} {
    #| Returns a list of the values for the given enumeration
    lassign [qc::db_resolve_type_name $enum_name] {*}{
        schema
        enum_name
    }
    set qry {
        SELECT e.enumlabel as value
        FROM pg_enum e 
        JOIN pg_type t
        ON t.oid = e.enumtypid
        JOIN pg_namespace n
        ON t.typnamespace = n.oid
        WHERE t.typname=:enum_name
        AND n.nspname=:schema;
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
    set parts [split $enum_name "."]
    if { [llength $parts] == 2 } {
        lassign $parts schema enum_name
        set qry {
            SELECT e.enumtypid
            FROM pg_enum e
            JOIN pg_type t
            ON t.oid = e.enumtypid
            JOIN pg_namespace n
            ON t.typnamespace = n.oid
            WHERE t.typname=:enum_name
            AND n.nspname=:schema
            LIMIT 1;
        }
    } else {
        set qry {
            SELECT e.enumtypid
            FROM pg_enum e
            JOIN pg_type t
            ON t.oid = e.enumtypid
            WHERE t.typname=:enum_name
            LIMIT 1;
        }
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
    set parts [split $domain_name "."]
    if { [llength $parts] == 2 } {
        lassign $parts domain_schema domain_name
        set qry {
            SELECT domain_name
            FROM information_schema.domains
            WHERE domain_name=:domain_name
            AND domain_schema=:domain_schema;
        }
    } else {
        set qry {
            SELECT domain_name
            FROM information_schema.domains
            WHERE domain_name=:domain_name
            LIMIT 1;
        }
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

proc qc::db_resolve_domain_name {name} {
    #| Resolve args to schema and domain
    set parts [split $name "."]
    switch [llength $parts] {
        2 { return $parts }
        1 {
            set domain_name [lindex $parts 0]
            db_cache_0or1row -ttl 86400 {
                select domain_schema

                from information_schema.domains,
                generate_series(1,
                                array_length(current_schemas(true),1)
                                ) as index

                where domain_schema = (current_schemas(true))\[index\]
                and domain_name=:domain_name

                order by index
                limit 1
            } {
                db_cache_1row -ttl 86400 {
                    select domain_schema

                    from information_schema.domains

                    where domain_name=:domain_name
                    
                    limit 1
                }
            }
            return [list $domain_schema $domain_name]
        }
        default {
            error "Unable to resolve domain name"
        }
    }
}

proc qc::db_domain_constraints {name} {
    #| Returns a dict of the constraint name with the check clause for the given domain in the database.
    lassign [qc::db_resolve_domain_name $name] {*}{
        domain_schema
        domain_name
    }
    set constraints [dict create]
    if {[qc::memoize qc::db_domain_exists $domain_name]} {
        set qry {
            SELECT cc.constraint_name, check_clause
            FROM information_schema.check_constraints cc
            JOIN information_schema.domain_constraints dc
            ON dc.constraint_name=cc.constraint_name
            AND dc.constraint_schema=cc.constraint_schema
            WHERE dc.domain_name=:domain_name
            AND dc.domain_schema=:domain_schema;
        }
        qc::db_cache_foreach -ttl 86400 $qry {
            dict set constraints $constraint_name $check_clause
        }
        return $constraints
    } else {
        return -code error -errorcode DB_DOMAIN "Domain \"$domain_name\" does not exist."
    }
}

proc qc::db_column_constraints {args} {
    #| Returns a dict of constraint name and check clause for the given column
    lassign [qc::db_qualify_column {*}$args] {*}{
        schema
        table
        column
    }
    if {[qc::db_table_column_exists $table $column]} {
        set qry {
            SELECT cc.constraint_name, check_clause
            FROM information_schema.check_constraints cc
            JOIN information_schema.constraint_column_usage ccu
            ON cc.constraint_name=ccu.constraint_name
            AND ccu.constraint_schema=cc.constraint_schema
            WHERE ccu.table_schema=:schema
            AND ccu.table_name=:table
            AND ccu.column_name=:column;
        }
        set constraints {}
        qc::db_cache_foreach -ttl 86400 $qry {
            lappend constraints $constraint_name $check_clause
        }
        return $constraints
    } else {
        return -code error -errorcode DB_COLUMN "Column \"$schema.$table.$column\" does not exist."
    }
}

proc qc::db_eval_constraint {args} {
    #| Check a db constraint expression by substituting in corresponding values from args
    # eg constraint_test {(col1 > col2)} col1 17 col2 16
    qc::args $args -schema ? -- table constraint args
    if { ! [info exists schema] } {
        lassign [qc::db_qualify_table $table] {*}{
            schema
            table
        }
    }
    set column_types [qc::memoize qc::db_table_column_types \
                          -qualified -- $schema $table]
    set columns [dict keys $column_types]
    set tq_columns [qc::map [list x "return $table.\$x"] $columns]
    set sq_columns [qc::map [list x "return $schema.$table.\$x"] $columns]
    set column_values [qc::dict_subset $args {*}$columns {*}$tq_columns {*}$sq_columns]
    set list {}
    foreach {name value} $column_values {
        lassign [qc::db_resolve_field_name $name] {*}{
            schema
            table
            column
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

proc qc::db_eval_column_constraints {args} {
    #| Evaluates constraints on the given table.column with the given values.
    #| Returns a dict of the constraints and their results.
    set values [lindex $args end]
    lassign [qc::db_qualify_column {*}[lrange $args 0 end-1]] {*}{
        schema
        table
        column
    }
    set constraints \
        [qc::memoize qc::db_column_constraints $schema $table $column]
    set results {}
    foreach {constraint_name check_clause} $constraints {
        lappend results $constraint_name \
            [qc::db_eval_constraint \
                 -schema $schema -- $table $check_clause {*}$values]
    }
    return $results
}

proc qc::db_domain_base_type {domain} {
    #| Returns the base type of the given domain.
    if { [qc::memoize qc::db_domain_exists $domain] } {
        lassign [qc::db_resolve_domain_name $domain] {*}{
            schema
            domain_name
        }
        set qry {
            SELECT
            udt_name,
            character_maximum_length,
            numeric_precision,
            numeric_scale

            FROM information_schema.domains

            WHERE domain_name=:domain_name
            AND domain_schema=:schema;
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
