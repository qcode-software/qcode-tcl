namespace eval qc {
    namespace export register validate
}

proc register {method path proc_args proc_body} {
    #| Register a URL handler.
    set method [string toupper $method]
    namespace eval ::${method} {}
    set proc_name "::${method}::$path"
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
    qc::nsv_dict set handlers $method $path proc_name $proc_name
    qc::nsv_dict set handlers $method $path args $args
    qc::nsv_dict set handlers $method $path body $proc_body
    qc::nsv_dict set handlers $method $path defaults $defaults    

    if {$method eq "GET"} {
        set http_methods [list HEAD GET]
    } else {
        set http_methods [list "POST"]
    }

    # Add path to the filters database if not present.
    foreach http_method $http_methods {
        if { ! [qc::nsv_dict exists filters filter_validate $http_method $path] } {
            qc::nsv_dict set filters filter_validate $http_method $path 1
        }
        if { ! [qc::nsv_dict exists filters filter_authenticate $http_method $path] } {
            qc::nsv_dict set filters filter_authenticate $http_method $path 1
        }
    }
}

proc validate {method path proc_args proc_body} {
    #| Register a URL handler for extra validation.
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