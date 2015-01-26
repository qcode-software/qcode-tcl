namespace eval qc {
    namespace export register validate
}

proc qc::register {args} {
    #| Register a URL handler.
    if { [llength $args] < 2 || [llength $args] > 4 } {
        return -code error "Usage: qc::register method path ?args? ?body?"
    }

    set method [string toupper [lindex $args 0]]
    set path [lindex $args 1]
    # Add to registered nsv array
    if { ! [qc::registered $method $path] } {
        qc::nsv_dict lappend registered $method $path
    }

    if { [llength $args] >= 3 } {
        set proc_args [lindex $args 2]
        # Separate arg names and default values
        set arg_names {}
        set defaults {}
        foreach arg $proc_args {
            if {[llength $arg] == 2} {
                lappend arg_names [lindex $arg 0]
                dict set defaults [lindex $arg 0] [lindex $arg 1]
            } else {
                lappend arg_names $arg
            }
        }
    }

    if { [llength $args] == 4 } {
        set proc_body [lindex $args 3]
        # Create the proc
        namespace eval ::${method} {}
        set proc_name "::${method}::$path"
        {*}[list proc $proc_name $proc_args $proc_body]

        # Update the handlers nsv array.
        qc::nsv_dict set handlers $method $path proc_name $proc_name
        qc::nsv_dict set handlers $method $path args $arg_names
        qc::nsv_dict set handlers $method $path body $proc_body
        qc::nsv_dict set handlers $method $path defaults $defaults  
    }
}

proc qc::validate {method path proc_args proc_body} {
    #| Register a URL handler for custom validation.
    set method [string toupper $method]
    set proc_name "::${method}::VALIDATE::$path"
    namespace eval ::${method}::VALIDATE {}
    {*}[list proc $proc_name $proc_args $proc_body]

    # Separate arg names and default values
    set args {}
    set defaults {}
    foreach arg $proc_args {
        if {[llength $arg] == 2} {
            lappend args [lindex $arg 0]
            dict set defaults [lindex $arg 0] [lindex $arg 1]
        } else {
            lappend args $arg
        }
    }
    
    # Update the handlers nsv array.
    qc::nsv_dict set handlers VALIDATE $method $path proc_name $proc_name
    qc::nsv_dict set handlers VALIDATE $method $path args $args 
    qc::nsv_dict set handlers VALIDATE $method $path body $proc_body 
    qc::nsv_dict set handlers VALIDATE $method $path defaults $defaults
}

proc qc::registered {method url_path} {
    #| Checks if the given method url_path is registered.
    set method [string toupper $method]
    if { [qc::nsv_dict exists registered $method] } {
        return [qc::path_matches $url_path [qc::nsv_dict get registered $method]]
    } else {
        return false
    }
}

proc qc::path_matches {url_path patterns} {
    #| Checks if the given url_path matches any of the given patterns.
    foreach pattern $patterns {
        set path_parts [split $url_path /]
        set pattern_parts [split $pattern /]
        # check number of parts in each path are equal
        if { [llength $path_parts] == [llength $pattern_parts] } {
            # check that each part matches
            set parts_equal true
            foreach path_part $path_parts pattern_part $pattern_parts {
                if {[string index $pattern_part 0] eq ":"} {
                    # if the item part is a colon variable
                    continue
                } elseif {$path_part ne $pattern_part} {
                    set parts_equal false
                    break
                }
            }
            if {$parts_equal} {
                return true
            }
        }
    }
    return false
}