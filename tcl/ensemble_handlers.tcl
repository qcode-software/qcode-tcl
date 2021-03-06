##################################################
#
# qc::is, qc::cast, qc::castable ensemble handler
#
###################################################
proc data_type_parser {args} {
    #| Try to map args to data type
    set namespace [lindex $args 0]
    set data_type [lindex $args 1]
    
    switch -regexp -matchvar numbers -- $data_type {
        {^varchar\(([0-9]+)\)$} {
            return [list $namespace varchar [lindex $numbers 1]]
        }
        {^char\(([0-9]+)\)$} {
            return [list $namespace char [lindex $numbers 1]]
        }
        {^(decimal|numeric)\(([0-9]+,[0-9]+)\)$} {
            set values [split [lindex $numbers 2] ,]
            return [list $namespace decimal -precision [lindex $values 0] -scale [lindex $values 1]]
        }
        {^(decimal|numeric)\(([0-9]+)\)$} {
            return [list $namespace decimal -precision [lindex $numbers 2]]
        }
        ^numeric$ {
            return [list $namespace decimal]
        }
        ^bool$ {
            return [list $namespace boolean]
        }
        {^(int|int4)$} {
            return [list $namespace integer]
        }
        ^int2$ {
            return [list $namespace smallint]
        }
        ^int8$ {
            return [list $namespace bigint]
        }
        ^float8$ {
            return [list $namespace decimal]
        }
        default {
            if { [regexp {\.([^\.]+)$} $data_type -> qc_data_type] && [info commands "${namespace}::${qc_data_type}"] ne "" } {
                # qcode-tcl data type prefixed by db schema - cast/validate using qcode-tcl 
                return [list $namespace $qc_data_type]
                
            } elseif { [qc::memoize qc::db_domain_exists $data_type] } {
                # db domain
                return [list $namespace domain $data_type]
                
            } elseif { [qc::memoize qc::db_enum_exists $data_type] } {
                # db enumerated type
                return [list $namespace enumeration $data_type]
                
            }
        }
    }
}

##################################################
#
# qc::response ensemble handler
#
##################################################
proc response_subcommand_map {ensemble subcommand args} {
    #| Map unknown subcommands to response extend
    return [list $ensemble extend $subcommand]
}
