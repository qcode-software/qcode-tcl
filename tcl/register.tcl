namespace eval qc {
    namespace export register validate
}

proc qc::register {args} {
    #| Register a URL handler.
    if { [llength $args] < 2 || [llength $args] > 5 } {
        return -code error "Usage: qc::register ?-no-auth? method path ?args? ?body?"
    }
    qc::args $args -no-auth -- args

    set method [string toupper [lindex $args 0]]
    set path [lindex $args 1]
    # Add to registered nsv dict if not already registered
    if { ! [qc::registered $method $path] } {
        qc::nsv_dict lappend registered $method $path
    }

    # Check authentication exemption
    if { ! [info exists no-auth] && ! [qc::registered authenticate $method $path]} {
        qc::nsv_dict lappend authenticate $method $path
    } elseif { [info exists no-auth] && [qc::registered authenticate $method $path] } {
        # Previously registered but now exempt from authentication - remove from nsv dict
        set paths [qc::nsv_dict get authenticate $method]
        set paths [qc::lexclude $paths $path]
        qc::nsv_dict set authenticate $method $paths
    }

    if { [llength $args] >= 3 } {
        set handler_args [lindex $args 2]
        set proc_args {}
        set handler_arg_names {}
        set defaults {}
        # Create arg defaults dict, arg name list, and set up args to be used in proc.
        foreach arg $handler_args {
            # Check if arg has default value
            if {[llength $arg] == 2} {
                set name [lindex $arg 0]
                set default_value [lindex $arg 1]
                dict set defaults $name $default_value
            } else {
                set name $arg
            }

            # Keep note of full qualified names for validation purposes.
            lappend handler_arg_names $name

            # Check if arg is fully qualified
            if { [regexp {^([^\.]+)\.([^\.]+)$} $name -> table column] } {
                # Check if $column or <qualifier>.$column appears anywhere else in the args
                set matches 0
                foreach temp $handler_args {
                    if { [llength $arg] == 2 } {
                        set temp2 [lindex $temp 0]
                    } else {
                        set temp2 $temp
                    }

                    if { $temp2 eq $column || [string match "?*.$column" $temp2] } {
                        incr matches
                    }
                }
                # Only 1 match is itself therefore it's safe to use unqualified name.
                if { $matches == 1 } {
                    set name $column
                }
            }
            # Add name and default value, if present, to arguments for proc definition.
            if { [llength $arg] == 2 } {
                lappend proc_args "$name $default_value"
            } else {
                lappend proc_args $name
            }
        }

        # Check that colon variables in the path appear in the args
        set path_parts [split $path /]
        foreach path_part $path_parts {
            if { [string first : $path_part] == 0 && [lsearch -exact $arg_names [string range $path_part 1 end]] == -1} {
                return -code error "Colon variable \"$path_part\" missing from args."
            }
        }
    }

    if { [llength $args] == 4 } {
        set proc_body [lindex $args 3]
        # Create the proc
        namespace eval ::${method} {}
        set proc_name "::${method}::$path"
        {*}[list proc $proc_name $proc_args $proc_body]

        # Update the handlers nsv dict
        qc::nsv_dict set handlers $method $path proc_name $proc_name
        qc::nsv_dict set handlers $method $path args $handler_arg_names
        qc::nsv_dict set handlers $method $path body $proc_body
        qc::nsv_dict set handlers $method $path defaults $defaults  
    }
}

proc qc::validate {method path handler_args proc_body} {
    #| Register a URL handler for custom validation.
    set proc_args {}
    set handler_arg_names {}
    set defaults {}
    # Create arg defaults dict, arg name list, and set up args to be used in proc.
    foreach arg $handler_args {
        # Check if arg has default value
        if {[llength $arg] == 2} {
            set name [lindex $arg 0]
            set default_value [lindex $arg 1]
            dict set defaults $name $default_value
        } else {
            set name $arg
        }

        # Keep note of full qualified names for validation purposes.
        lappend handler_arg_names $name

        # Check if arg is fully qualified
        if { [regexp {^([^\.]+)\.([^\.]+)$} $name -> table column] } {
            # Check if $column or <qualifier>.$column appears anywhere else in the args
            set matches 0
            foreach temp $handler_args {
                if { [llength $arg] == 2 } {
                    set temp2 [lindex $temp 0]
                } else {
                    set temp2 $temp
                }

                if { $temp2 eq $column || [string match "?*.$column" $temp2] } {
                    incr matches
                }
            }
            # Only 1 match is itself therefore it's safe to use unqualified name.
            if { $matches == 1 } {
                set name $column
            }
        }
        # Add name and default value, if present, to arguments for proc definition.
        if { [llength $arg] == 2 } {
            lappend proc_args "$name $default_value"
        } else {
            lappend proc_args $name
        }
    }

    # Create the proc
    set method [string toupper $method]
    set proc_name "::${method}::VALIDATE::$path"
    namespace eval ::${method}::VALIDATE {}
    {*}[list proc $proc_name $proc_args $proc_body]

    
    # Update the handlers nsv array.
    qc::nsv_dict set handlers VALIDATE $method $path proc_name $proc_name
    qc::nsv_dict set handlers VALIDATE $method $path args $handler_arg_names
    qc::nsv_dict set handlers VALIDATE $method $path body $proc_body 
    qc::nsv_dict set handlers VALIDATE $method $path defaults $defaults
}

proc qc::registered {args} {
    #| Checks if the given method url_path is registered.
    if { [llength $args] < 2 || [llength $args] > 3 } {
        return -code error "Usage: qc::registered ?service? method path"
    }
    
    if { [llength $args] == 3 } {
        set service [lindex $args 0]
        set method [string toupper [lindex $args 1]]
        set path [lindex $args 2]
    } else {
        set service registered
        set method [string toupper [lindex $args 0]]
        set path [lindex $args 1]
    }
    
    if { [qc::nsv_dict exists $service $method] } {
        return [qc::path_matches $path [qc::nsv_dict get $service $method]]
    } else {
        return false
    }
}

proc qc::path_matches {path patterns} {
    #| Checks if the given path matches any of the given patterns.
    foreach pattern $patterns {
        set path_parts [split $path /]
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

proc qc::path_best_match {path patterns} {
    #| Finds the best match to path from the given patterns.
    set path_parts [split $path /]
    set matches {}
    foreach pattern $patterns {
        set pattern_parts [split $pattern /]
        # Check if path and pattern have the same number of parts
        if { [llength $path_parts] != [llength $pattern_parts] } {
            continue
        }
        set parts_equal true
        foreach path_part $path_parts pattern_part $pattern_parts {
            if { $path_part ne $pattern_part && [string first : $pattern_part] != 0 } {
                # Parts are not the same and the pattern part is not a colon variable
                set parts_equal false
            }
        }

        if { ! $parts_equal } {
            continue
        }

        # count the number of colon variables in the pattern
        set colon_variable_count [regexp -all {[^:]:[^:]+(?=/|$)} $pattern]
        # Add it to the matches dict
        dict lappend matches $colon_variable_count $pattern
    }
    
    # Get the lowest count of colon variables in a matched pattern.
    foreach count [dict keys $matches] {
        if { ! [info exists best_match_count] || $count < $best_match_count} {
            set best_match_count $count
        }
    }
    
    # If there were matches found then return one with the least amount of colon variables.
    if { [dict size $matches] > 0 } {
        return [lindex [dict get $matches $best_match_count] 0]
    } else {
        return -code error "No pattern matched path: \"$path\""
    }
}

proc qc::path_variables {path pattern} {
    #| Gets variables from the path that corresponds to colon variables in the pattern.
    set path_parts [split $path /]
    set pattern_parts [split $pattern /]
    set variables {}
    foreach path_part $path_parts pattern_part $pattern_parts {
        if { [string first : $pattern_part ] == 0 } {
            # The pattern part is a colon variable - store the path_part
            dict set variables [string range $pattern_part 1 end] $path_part
        }
    }
    return $variables
}