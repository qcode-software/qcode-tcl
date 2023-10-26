namespace eval qc::handlers {

    namespace export call exists validate2model validation
    namespace ensemble create

    proc call {method path} {
        #| Call the registered handler that matches the given path and method.
        set method [string toupper $method]
        set pattern [qc::path_best_match $path [get $method]]
        # Gather a list of form variables we might be interested in and add in
        # path variables to the form data.
        set args [args $method $pattern]
        foreach arg $args {
            set shortname [qc::arg_shortname $arg]
            if { $shortname ne $arg } {
                lappend args $shortname
            }
        }
        set form [dict merge [qc::form2dict {*}$args] [qc::path_variables $path $pattern]]
        # Cast to model
        set dict [qc::cast_values2model {*}[data $form $method $pattern]]
        # Call handler
        return [qc::call_with [proc_name $method $pattern] {*}$dict]
    }

    proc exists {method path} {
        #| Check if a handler exists for the given path and method.
        return [qc::path_matches $path [get [string toupper $method]]]
    }

    proc validate2model {method path} {
        #| Validates the args of the handler registered for the given path and method.
        set method [string toupper $method]
        set pattern [qc::path_best_match $path [get $method]]
        # Gather a list of form variables we might be interested in and add in
        # path variables to the form data.
        set args [args $method $pattern]
        foreach arg $args {
            set shortname [qc::arg_shortname $arg]
            if { $shortname ne $arg } {
                lappend args $shortname
            }
        }
        set form [dict merge [qc::form2dict {*}$args] [qc::path_variables $path $pattern]]
        # Validate the data.
        return [qc::validate2model [data $form $method $pattern]]
    }

    ##################################################
    #
    # Private procs
    #
    ##################################################

    proc get {{method ""}} {
        #| Get all patterns.
        #| If method has been given then return only patterns that match the given method.
        if { ! [nsv_array exists "handlers.patterns"] } {
            return [list]
        } elseif { $method ne "" } {
            if { [nsv_exists "handlers.patterns" $method] } {
                return [nsv_get "handlers.patterns" $method]
            } else {
                return [list]
            }
        } else {
            return [concat {*}[dict values [nsv_array get "handlers.patterns"]]]
        }
    }
    
    proc proc_name {method pattern} {
        #| Get the proc name for the handler identified by $method $pattern.
        return [nsv_get "handlers.${method}.proc_names" $pattern]
    }

    proc args {method pattern} {
        #| Get all arguments for the given handler identified by $method $pattern.
        return [nsv_get "handlers.${method}.args" $pattern]
    }

    proc default {method pattern arg} {
        #| Get the default value of the given arg for the handler identified by $method $pattern.
        return [qc::nsv_dict get "handlers.${method}.defaults" $pattern $arg]
    }

    proc default_exists {method pattern arg} {
        #| Check if a default argument exists for the given argument for handler identified by $method $pattern.
        return [qc::nsv_dict exists "handlers.${method}.defaults" $pattern $arg]
    }

    proc data {form method pattern} {
        #| Returns a dictionary of data for the handler identified by $method $pattern.
        set method [string toupper $method]
        set args [args $method $pattern]
        set unambiguous [qc::args_unambiguous {*}$args]
        set result {}
        foreach arg $args {
            # Check if a form variable exists for $arg
            if { [dict exists $form $arg] } {
                lappend result $arg [dict get $form $arg]
                continue
            }

            # Check if shortname of $arg is unambiguous and exists as a form variable
            set shortname [qc::arg_shortname $arg]
            if { [llength [lsearch -all $unambiguous $arg]] && [dict exists $form $shortname] } {
                lappend result $arg [dict get $form $shortname]
                continue
            }

            # Check if default value exists for $arg
            if { [default_exists $method $pattern $arg] } {
                lappend result $arg [default $method $pattern $arg]
                continue
            }
            
            # $arg wasn't optional and didn't appear in form
            return \
                -code error \
                -errorcode INVALID_REQUEST \
                "No matching arg value for \"$arg\" in form."
        }
        return $result
    }


    ##################################################
    #
    # qc::handlers validation
    #
    ##################################################
    
    namespace eval validation {

        namespace export call exists
        namespace ensemble create

        proc call {method path} {
            #| Calls the registered handler that matches the given method and path.
            set method [string toupper $method]
            set pattern [qc::path_best_match $path [get $method]]
            # Gather a list of form variables we might be interested in and add in
            # path variables to the form data.
            set args [args $method $pattern]
            foreach arg $args {
                set shortname [qc::arg_shortname $arg]
                if { $shortname ne $arg } {
                    lappend args $shortname
                }
            }
            set form [dict merge [qc::form2dict {*}$args] [qc::path_variables $path $pattern]]
            # Grab relevant arg data from form.
            set dict [qc::cast_values2model {*}[data $form $method $pattern]]
            # Call the validation handler.
            return [qc::call_with [proc_name $method $pattern] {*}$dict]
        }

        proc exists {method path} {
            #| Checks if a validation handler exists for the given path and method.
            return [qc::path_matches $path [get [string toupper $method]]]
        }

        ##################################################
        #
        # qc::handlers validation
        # Private procs
        #
        ##################################################

        proc get {{method ""}} {
            #| Get all the validation handler paths.
            #| If method has been given then return only handlers that match method.
            if { ! [nsv_array exists "handlers.VALIDATE.patterns"] } {
                return [list]
            } elseif { $method ne "" } {
                if { [nsv_exists "handlers.VALIDATE.patterns" $method] } {
                    return [nsv_get "handlers.VALIDATE.patterns" $method]
                } else {
                    return [list]
                }
            } else {
                return [concat {*}[dict values [nsv_array get "handlers.VALIDATE.patterns"]]]
            }
        }
        
        proc proc_name {method pattern} {
            #| Get the validation proc_name for the handler identified by $method $pattern.
            return [nsv_get "handlers.VALIDATE.${method}.proc_names" $pattern]
        }

        proc args {method pattern} {
            #| Get all arguments for the handler identified by $method $pattern.
            return [nsv_get "handlers.VALIDATE.${method}.args" $pattern]
        }

        proc default {method pattern arg} {
            #| Get the default value of the given arg for the handler identified by $method $pattern.
            return [qc::nsv_dict get "handlers.VALIDATE.${method}.defaults" $pattern $arg]
        }

        proc default_exists {method pattern arg} {
            #| Check if a default argument exists for the given argument for handler identified by $method $pattern.
            return [qc::nsv_dict exists "handlers.VALIDATE.${method}.defaults" $pattern $arg]
        }

        proc data {form method pattern} {
            #| Returns a dictionary of args for the handler identified by $method $pattern.
            set method [string toupper $method]
            set args [args $method $pattern]
            set unambiguous [qc::args_unambiguous {*}$args]
            set result {}
            foreach arg $args {
                # Check if a form variable exists for $arg
                if { [dict exists $form $arg] } {
                    lappend result $arg [dict get $form $arg]
                    continue
                }

                # Check if shortname of $arg is unambiguous and exists as a form variable
                set shortname [qc::arg_shortname $arg]
                if { [llength [lsearch -all $unambiguous $arg]] && [dict exists $form $shortname] } {
                    lappend result $arg [dict get $form $shortname]
                    continue
                }

                # Check if default value exists for $arg
                if { [default_exists $method $pattern $arg] } {
                    lappend result $arg [default $method $pattern $arg]
                    continue
                }
                
                # arg wasn't optional and didn't appear in form
                return -code error "No matching arg value for \"$arg\" in form." 
            }
            return $result
        }
    }
}
