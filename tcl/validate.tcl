namespace eval qc {
}

proc qc::validate2model {dict} {
    #| Validates dictionary against the data model and sets up the record in the global data structure.
    #| First checks all types. If all are valid, proceeds to check constraints.
    set all_valid true
    set cast_dict [dict create]
    dict for {name value} $dict {
        # Resolve name to column, table, and schema
        lassign [qc::memoize qc::db_resolve_field_name $name] {*}{
            schema
            table
            column
        }
        set message [qc::memoize qc::db_validation_message $table $column]
        set data_type [qc::memoize qc::db_column_type \
                           -qualified -- $schema $table $column]
        set nullable [qc::memoize qc::db_column_nullable $schema $table $column]

        # Check if this is a sensitive data type - values should not be echo'd back to the client
        if { $data_type in [list "password" "card_number"] } {
            # Mark field as being sensitive in the global data structure
            qc::response record sensitive $column
        }
        # Initialise valid flag
        qc::response record valid $column $value
        # Check if nullable
        if {! $nullable && $value eq ""} {
            qc::response record invalid $column $value $message
            set all_valid false
            continue
        } elseif {$nullable && $value eq ""} {
            dict set cast_dict $name ""
            continue
        }
        # Check value against data type
        if { ![qc::castable $data_type $value] } {
            qc::response record invalid $column $value $message
            set all_valid false
            continue
        } 
        dict set cast_dict $name [qc::cast $data_type $value]
    }

    if { $all_valid } {
        # continue to do the constraint checking
        dict for {name value} $cast_dict {

            # Check if null
            if { $value eq ""} {
                continue
            }

            # Resolve name to column, table, and schema
            lassign [qc::memoize qc::db_resolve_field_name $name] {*}{
                schema
                table
                column
            }

            set message [qc::memoize qc::db_validation_message $table $column]

            # Check constraints
            set constraint_results [qc::db_eval_column_constraints $schema $table $column $cast_dict]
            if {[llength $constraint_results] > 0 && ! [expr [join [dict values $constraint_results] " && "]] } {
                # Constraint checking failed - skip further checks
                qc::response record invalid $column $value $message
                set all_valid false
                continue
            }         
        }
    }

    if { ! $all_valid } {
        qc::response status invalid
    } else {
        qc::response status valid
    }
    
    return $all_valid
}
