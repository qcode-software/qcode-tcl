namespace eval qc::handlers {

    namespace export call exists validate2model validation
    namespace ensemble create

    proc call {method path} {
        #| Call the registered handler that matches the given path and method.
        set method [string toupper $method]
        set pattern [qc::path_best_match $path [get $method]]
        set form_dict [dict merge [qc::form2dict] [qc::path_variables $path $pattern]]
        set args_dict [qc::dict_zipper [args $method $pattern] [args_from_dict $form_dict $method $pattern]]
        return [[proc_name $method $pattern] {*}[dict values [qc::cast_values2model {*}$args_dict]]]
    }

    proc exists {method path} {
        #| Check if a handler exists for the given path and method.
        return [qc::path_matches $path [get [string toupper $method]]]
    }

    proc validate2model {method path} {
        #| Validates the args of the handler registered for the given path and method.
        set method [string toupper $method]
        set pattern [qc::path_best_match $path [get $method]]
        set form_dict [dict merge [qc::form2dict] [qc::path_variables $path $pattern]]
        set arg_values [args_from_dict $form_dict $method $pattern]        
        return [qc::validate2model [qc::dict_zipper [args $method $pattern] $arg_values]]
    }

    ##################################################
    #
    # Private procs
    #
    ##################################################

    proc get {{method ""}} {
        #| Get all patterns.
        #| If method has been given then return only patterns that match the given method.
        set temp {}
        if { $method eq "" && [nsv_exists handlers] } {
            dict for {method handlers} [nsv_get handlers] {
                lappend temp {*}[dict keys $handlers]
            }
        } elseif { $method ne "" && [qc::nsv_dict exists handlers [string toupper $method]] } {
            lappend temp {*}[dict keys [qc::nsv_dict get handlers [string toupper $method]]]
        }
        return $temp
    }
    
    proc proc_name {method pattern} {
        #| Get the proc name for the handler named "$method $pattern".
        return [qc::nsv_dict get handlers $method $pattern proc_name]
    }

    proc args {method pattern} {
        #| Get all arguments for the given handler named "$method $pattern".
        return [qc::nsv_dict get handlers $method $pattern args]
    }

    proc default {method pattern arg} {
        #| Get the default value of the given arg for the handler named "$method $pattern".
        return [qc::nsv_dict get handlers $method $pattern defaults $arg]
    }

    proc default_exists {method pattern arg} {
        #| Check if a default argument exists for the given argument for handler named "$method $pattern".
        return [qc::nsv_dict exists handlers $method $pattern defaults $arg]
    }

    proc args_from_dict {dict method pattern} {
        #| Returns a list of args for the handler named "$method $pattern" that correspond to any form variables in the given dictionary.
        set method [string toupper $method]
        set args [args $method $pattern]
        set handler_args {}
        foreach arg $args {
            if {[default_exists $method $pattern $arg]} {
                # the argument was an optional one 
                if {[dict exists $dict $arg]} {
                    lappend handler_args [dict get $dict $arg]
                } elseif { [regexp {^[^.]+\.([^.]+)$} $arg -> column] && [dict exists $dict $column] } {
                    # Return the first form value matching a fully qualified handler arg
                    # eg. Use form var firstname for arg users.firstname
                    lappend handler_args [dict get $dict $column]
                } else {
                    lappend handler_args [default $method $pattern $arg]
                }
            } elseif {[dict exists $dict $arg]} {
                lappend handler_args [dict get $dict $arg]
            } else {
                # arg wasn't optional and didn't appear in form_dict 
                return -code error "No matching arg value for \"$arg\" in handler \"$method $pattern\"" 
            }
        }
        return $handler_args
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
            set form_dict [dict merge [qc::form2dict] [qc::path_variables $path $pattern]]
            return [[proc_name $method $pattern] {*}[args_from_dict $form_dict $method $pattern]]
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
            set temp {}
            if { $method eq "" && [qc::nsv_dict exists handlers VALIDATE] } {
                dict for {method handlers} [qc::nsv_dict get handlers VALIDATE] {
                    lappend temp {*}[dict keys $handlers]
                }
            } elseif { $method ne "" && [qc::nsv_dict exists handlers VALIDATE [string toupper $method]] } {
                lappend temp {*}[dict keys [qc::nsv_dict get handlers VALIDATE [string toupper $method]]]
            }
            return $temp
        }
        
        proc proc_name {method pattern} {
            #| Get the validation proc_name for the handler named "$method $pattern".
            return [qc::nsv_dict get handlers VALIDATE $method $pattern proc_name]
        }

        proc args {method pattern} {
            #| Get all arguments for the handler named "$method $pattern".
            return [qc::nsv_dict get handlers VALIDATE $method $pattern args]
        }

        proc default {method pattern arg} {
            #| Get the default value of the given arg for the handler named "$method $pattern".
            return [qc::nsv_dict get handlers VALIDATE $method $pattern defaults $arg]
        }

        proc default_exists {method pattern arg} {
            #| Check if a default argument exists for the given argument for handler named "$method $pattern".
            return [qc::nsv_dict exists handlers VALIDATE $method $pattern defaults $arg]
        }

        proc args_from_dict {dict method pattern} {
            #| Returns a list of args for the handler named "$method $pattern" that correspond to any form variables in the given dictionary
            set method [string toupper $method]
            set args [args $method $pattern]
            set handler_args {}
            foreach arg $args {
                if {[default_exists $method $pattern $arg]} {
                    # the argument was an optional one 
                    if {[dict exists $dict $arg]} {
                        lappend handler_args [dict get $dict $arg]
                    } elseif { [regexp {^[^.]+\.([^.]+)$} $arg -> column] && [dict exists $dict $column] } {
                        # Return the first form value matching a fully qualified handler arg
                        # eg. Use form var firstname for arg users.firstname
                        lappend handler_args [dict get $dict $column]
                    } else {
                        lappend handler_args [default $method $pattern $arg]
                    }
                } elseif {[dict exists $dict $arg]} {
                    lappend handler_args [dict get $dict $arg]
                } else {
                    # arg wasn't optional and didn't appear in form_dict 
                    return -code error "No matching arg value for \"$arg\" in handler \"$method $pattern\"" 
                }
            }
            return $handler_args
        }
    }
}