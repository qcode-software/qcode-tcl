namespace eval qc {
}

proc qc::validate {dict} {
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
        
        # Check if nullable
        if {! $nullable && $value eq ""} {
            qc::record invalid $name $value $message
            set all_valid false
            continue
        } elseif {$nullable && $value eq ""} {
            qc::record valid $name $value ""
            continue
        }
        # Check value against data type
        if {[qc::castable $data_type $value]} {
            set type_check true
        } else {
            set type_check false
        }

        # Check constraints
        set constraint_results [qc::db_eval_column_constraints $table $column $dict]
        if {! $type_check || ([llength $constraint_results] > 0 && ! [expr [join [dict values $constraint_results] " && "]]) } {
            qc::record invalid $name $value $message
            set all_valid false
        } elseif {$type_check} {
            qc::record valid $name [qc::cast $data_type $value] ""
        }
    }
    return $all_valid
}
