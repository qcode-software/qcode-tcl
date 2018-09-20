##################################################
#
# qc::is, qc::cast, qc::castable ensemble handler
#
###################################################
proc data_type_parser {args} {
    qc::log "** $args **"
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
            return ""
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
