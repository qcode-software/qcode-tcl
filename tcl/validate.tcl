namespace eval qc {
}

proc qc::validate2model {dict} {
    #| Validates dictionary against the data model and sets up the record in the global data structure.
    #| Returns true if all the data is valid otherwise false.
    set all_valid true
    dict for {name value} $dict {
        # Check if name is fully qualified
        if {![regexp {^([^\.]+)\.([^\.]+)$} $name -> table column] } {
            lassign [qc::db_qualified_table_column $name] table column
        }
        set message [qc::db_validation_message $table $column]
        set data_type [qc::db_column_type $table $column]
        set nullable [qc::db_column_nullable $table $column]

        # Check if this is a sensitive data type - values should not be echo'd back to the client
        if { $data_type in [list "password" "card_number"] } {
            # Mark field as being sensitive in the global data structure
            qc::response record sensitive $column
        }
        # Check if nullable
        if {! $nullable && $value eq ""} {
            qc::response record invalid $column $value $message
            set all_valid false
            continue
        } elseif {$nullable && $value eq ""} {
            qc::response record valid $column $value
            continue
        }
        # Check value against data type
        if { ![qc::castable $data_type $value] } {
            qc::response record invalid $column $value $message
            set all_valid false
            continue
        } 
    }

    if { $all_valid } {
        # continue to do the constraint checking
        dict for {name value} $dict {

            # Check if name is fully qualified
            if {![regexp {^([^\.]+)\.([^\.]+)$} $name -> table column] } {
                lassign [qc::db_qualified_table_column $name] table column
            }
            set message [qc::db_validation_message $table $column]
            set data_type [qc::db_column_type $table $column]

            # Check if null
            if { $value eq ""} {
                continue
            }
        
            # Check constraints
            set constraint_results [qc::db_eval_column_constraints $table $column $dict]
            if {[llength $constraint_results] > 0 && ! [expr [join [dict values $constraint_results] " && "]] } {
                # Constraint checking failed - skip further checks
                qc::response record invalid $column $value $message
                set all_valid false
                continue
            }         
        
            # Record passed all data model validation
            qc::response record valid $column [qc::cast $data_type $value]        
        }
    }

    if { ! $all_valid } {
        qc::response status invalid
    } else {
        qc::response status valid
    }
    
    return $all_valid
}
