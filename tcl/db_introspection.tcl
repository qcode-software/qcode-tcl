namespace eval qc {
    namespace export db_*
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
