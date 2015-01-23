namespace eval qc::handlers {

    namespace export call exists validate2model validation
    namespace ensemble create

    proc call {method path} {
        #| Call the registered handler that matches the given path and method.
        set url_parts [split $path /]
        set method [string toupper $method]
        set patterns [get $method]
        set form_dict [qc::form2dict]
        set proc_dict {}
        set pattern_dict {}
        
        foreach pattern $patterns {
            set parts [split $pattern /]
            set arg_names [args $pattern $method]
            # make sure that all colon variables appear in the handler args
            set move_on false
            foreach part $parts {
                if {[string first : $part] == 0 && [lsearch -exact $arg_names [string range $part 1 end]] == -1} {
                    set move_on true
                    break
                }
            }
            if {$move_on} { continue }
            
            # count the number of colon variables in the pattern
            set no_vars [regexp -all {[^:]:[^:]+(?=/|$)} $pattern]
            # Check length of parts matches and that the number of arguments for the handler is
            # not less than the number of colon variables in the pattern.
            if { [llength $parts] != [llength $url_parts] || [llength $arg_names] < $no_vars } {
                continue
            }

            set args {}
            set url_pattern_parts {}
            set colon_vars false
            set colon_count 0
            # check that each part of the pattern matches the corresponding url_path part 
            foreach part $parts url_part $url_parts {
                if {[qc::url_decode $url_part] eq $part} {
                    lappend url_pattern_parts $part
                } elseif {[string first : $part] == 0 } {
                    # the first character of the pattern part was ':'
                    # so update the args with the url_part
                    lappend args [string range $part 1 end] [qc::url_decode $url_part]
                    lappend url_pattern_parts $part
                    set colon_vars true
                    incr colon_count
                }
            }

            # check if the built url_pattern_parts is the same as the pattern
            if {[join $url_pattern_parts /] eq $pattern} {
                # Get the relevant args for the handler from the form variables.
                set form_dict [dict merge $form_dict $args]
                set args [args_from_dict $form_dict $pattern $method]
                set command [list $pattern {*}$args]
                if {$colon_vars} {
                    # The proc contains colon variables
                    if { [info exists pattern_dict] && [dict exists $pattern_dict variable]} {
                        # There is currently a colon variable command in the dictionary...
                        if { $colon_count < [dict get $pattern_dict variable colon_count] } {
                            # Prefer the command with the lower number of colon variables
                            dict set pattern_dict variable command $command colon_count $colon_count
                        }
                    } else {
                        # No colon variable command currently stored.
                        dict set pattern_dict variable command $command colon_count $colon_count
                    }                    
                } else {
                    # The pattern was an exact match
                    dict set pattern_dict exact command $command
                    break
                }
            }
        }
        
        # Call the proc and return the result. Prefer the exact match.
        if {[dict exists $pattern_dict exact]} {
            set command [dict get $pattern_dict exact command]
        } elseif [dict exists $pattern_dict variable] {
            set command [dict get $pattern_dict variable command]
        }
        set pattern [lindex $command 0]
        set args_dict [qc::dict_zipper [args $pattern $method] [lrange $command 1 end]]
        return [[proc_name $pattern $method] {*}[dict values [qc::cast_values2model {*}$args_dict]]]
    }

    proc exists {method path} {
        #| Check if a handler exists for the given path and method.
        set url_parts [split $path /]
        set method [string toupper $method]
        set patterns [get $method]
        foreach pattern $patterns {
            set parts [split $pattern /]
            set arg_names [args $pattern $method]
            # make sure that all colon variables appear in the handler args
            set move_on false
            foreach part $parts {
                if {[string first : $part] == 0 && [lsearch -exact $arg_names [string range $part 1 end]] == -1} {
                    set move_on true
                    break
                }
            }
            if {$move_on} { continue }
            
            # count the number of colon variables in the pattern
            set no_vars [regexp -all {[^:]:[^:]+(?=/|$)} $pattern]
            # Check length of parts matches and that the number of arguments for the handler is
            # not less than the number of colon variables in the pattern.
            if { [llength $parts] != [llength $url_parts] || [llength $arg_names] < $no_vars } {
                continue
            }

            set url_pattern_parts {}
            # check that each part of the pattern matches the corresponding path part 
            foreach part $parts url_part $url_parts {
                if {[qc::url_decode $url_part] eq $part} {
                    lappend url_pattern_parts $part
                } elseif {[string first : $part] == 0 } {
                    # the first character of the pattern part was ':'
                    lappend url_pattern_parts $part
                }
            }

            # check if the built url_pattern_parts is the same as the handler
            if {[join $url_pattern_parts /] eq $pattern} {
                return true
            }        
        }
        return false
    }

    proc validate2model {method path} {
        #| Validates the args of the handler registered for the given path and method.
        set url_parts [split $path /]
        set method [string toupper $method]
        set patterns [get $method]
        set form_dict [qc::form2dict]
        set proc_dict {}
        set pattern_dict {}
        
        foreach pattern $patterns {
            set parts [split $pattern /]
            set arg_names [args $pattern $method]
            # make sure that all colon variables appear in the handler args
            set move_on false
            foreach part $parts {
                if {[string first : $part] == 0 && [lsearch -exact $arg_names [string range $part 1 end]] == -1} {
                    set move_on true
                    break
                }
            }
            if {$move_on} { continue }
            
            # count the number of colon variables in the pattern
            set no_vars [regexp -all {[^:]:[^:]+(?=/|$)} $pattern]
            # Check length of parts matches and that the number of arguments for the handler is
            # not less than the number of colon variables in the pattern.
            if { [llength $parts] != [llength $url_parts] || [llength $arg_names] < $no_vars } {
                continue
            }

            set args {}
            set url_pattern_parts {}
            set colon_vars false
            # check that each part of the pattern  matches the corresponding url_path part 
            foreach part $parts url_part $url_parts {
                if {[qc::url_decode $url_part] eq $part} {
                    lappend url_pattern_parts $part
                } elseif {[string first : $part] == 0 } {
                    # the first character of the handler part was ':'
                    # so update the args with the url_part
                    lappend args [string range $part 1 end] [qc::url_decode $url_part]
                    lappend url_pattern_parts $part
                    set colon_vars true
                }
            }

            # check if the built url_pattern_parts is the same as the pattern
            if {[join $url_pattern_parts /] eq $pattern} {
                # Get the relevant args for the handler from the form variables.
                set form_dict [dict merge $form_dict $args]
                set args [args_from_dict $form_dict $pattern $method]
                set command [list $pattern {*}$args]
                if {$colon_vars} {
                    # The proc contains colon variables
                    if { [info exists pattern_dict] && [dict exists $pattern_dict variable]} {
                        # There is currently a colon variable command in the dictionary...
                        if { $colon_count < [dict get $pattern_dict variable colon_count] } {
                            # Prefer the command with the lower number of colon variables.
                            dict set pattern_dict variable command $command colon_count $colon_count
                        }
                    } else {
                        # No colon variable command currently stored.
                        dict set pattern_dict variable command $command colon_count $colon_count
                    }
                } else {
                    # The pattern was an exact match
                    dict set pattern_dict exact command $command
                    break
                }
            }
        }

        # Return the arg dict. Prefer the exact match.
        if {[dict exists $pattern_dict exact]} {
            set command [dict get $pattern_dict exact command]
        } elseif [dict exists $pattern_dict variable] {
            set command [dict get $pattern_dict variable command]
        }
        
        return [qc::validate2model [qc::dict_zipper [args [lindex $command 0] $method] [lrange $command 1 end]]]
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
    
    proc proc_name {pattern method} {
        #| Get the proc name for the handler named "$method $pattern".
        return [qc::nsv_dict get handlers $method $pattern proc_name]
    }

    proc args {pattern method} {
        #| Get all arguments for the given handler named "$method $pattern".
        return [qc::nsv_dict get handlers $method $pattern args]
    }

    proc default {pattern method arg} {
        #| Get the default value of the given arg for the handler named "$method $pattern".
        return [qc::nsv_dict get handlers $method $pattern defaults $arg]
    }

    proc default_exists {pattern method arg} {
        #| Check if a default argument exists for the given argument for handler named "$method $pattern".
        return [qc::nsv_dict exists handlers $method $pattern defaults $arg]
    }

    proc args_from_dict {dict pattern method} {
        #| Returns a list of args for the handler named "$method $pattern" that correspond to any form variables in the given dictionary.
        set method [string toupper $method]
        set args [args $pattern $method]
        set handler_args {}
        foreach arg $args {
            if {[default_exists $pattern $method $arg]} {
                # the argument was an optional one 
                if {[dict exists $dict $arg]} {
                    lappend handler_args [dict get $dict $arg]
                } elseif { [regexp {^[^.]+\.([^.]+)$} $arg -> column] && [dict exists $dict $column] } {
                    # Return the first form value matching a fully qualified handler arg
                    # eg. Use form var firstname for arg users.firstname
                    lappend handler_args [dict get $dict $column]
                } else {
                    lappend handler_args [default $pattern $method $arg]
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
            set url_parts [split $path /]
            set method [string toupper $method]
            set patterns [get $method]
            set form_dict [qc::form2dict]
            set proc_dict {}
            set pattern_dict {}
            
            foreach pattern $patterns {
                set parts [split $pattern /]
                set arg_names [args $pattern $method]
                # make sure that all colon variables appear in the handler args
                set move_on false
                foreach part $parts {
                    if {[string first : $part] == 0 && [lsearch -exact $arg_names [string range $part 1 end]] == -1} {
                        set move_on true
                        break
                    }
                }
                if {$move_on} { continue }
                
                # count the number of colon variables in the pattern
                set no_vars [regexp -all {[^:]:[^:]+(?=/|$)} $pattern]
                # Check length of parts matches and that the number of arguments for the handler is
                # not less than the number of colon variables in the pattern.
                if { [llength $parts] != [llength $url_parts] || [llength $arg_names] < $no_vars } {
                    continue
                }

                set args {}
                set url_pattern_parts {}
                set colon_vars false
                # check that each part of the handler matches the corresponding url_path part 
                foreach part $parts url_part $url_parts {
                    if {[qc::url_decode $url_part] eq $part} {
                        lappend url_pattern_parts $part
                    } elseif {[string first : $part] == 0 } {
                        # the first character of the handler part was ':'
                        # so update the args with the url_part
                        lappend args [string range $part 1 end] [qc::url_decode $url_part]
                        lappend url_pattern_parts $part
                        set colon_vars true
                    }
                }

                # check if the built url_pattern_parts is the same as the pattern
                if {[join $url_pattern_parts /] eq $pattern} {
                    # Get the relevant args for the handler from the form variables.
                    set form_dict [dict merge $form_dict $args]
                    set args [args_from_dict $form_dict $pattern $method]
                    set command [list [proc_name $pattern $method] {*}$args]
                    if {$colon_vars} {
                        # The proc contains colon variables
                        if { [info exists pattern_dict] && [dict exists $pattern_dict variable]} {
                            # There is currently a colon variable command in the dictionary...
                            if { $colon_count < [dict get $pattern_dict variable colon_count] } {
                                # Prefer the command with the lower number of colon variables.
                                dict set pattern_dict variable command $command colon_count $colon_count
                            }
                        } else {
                            # No colon variable command currently stored.
                            dict set pattern_dict variable command $command colon_count $colon_count
                        }
                    } else {
                        # The pattern was an exact match
                        dict set pattern_dict exact command $command
                        break
                    }
                }
            }

            # Call the handler. Prefer the exact match.
            if {[dict exists $pattern_dict exact]} {
                return [{*}[dict get $pattern_dict exact command]]
            } elseif [dict exists $pattern_dict variable] {
                return [{*}[dict get $pattern_dict variable command]]
            }
        }

        proc exists {method path} {
            #| Checks if a validation handler exists for the given path and method.
            set url_parts [split $path /]
            set method [string toupper $method]
            set handlers [get $method]
            foreach handler $handlers {
                set parts [split $handler /]
                set arg_names [args $handler $method]
                # make sure that all colon variables appear in the handler args
                set move_on false
                foreach part $parts {
                    if {[string first : $part] == 0 && [lsearch -exact $arg_names [string range $part 1 end]] == -1} {
                        set move_on true
                        break
                    }
                }
                if {$move_on} { continue }
                
                # count the number of colon variables in the pattern
                set no_vars [regexp -all {[^:]:[^:]+(?=/|$)} $handler]
                # Check length of parts matches and that the number of arguments for the handler is
                # not less than the number of colon variables in the pattern.
                if { [llength $parts] != [llength $url_parts] || [llength $arg_names] < $no_vars } {
                    continue
                }

                set url_pattern_parts {}
                # check that each part of the pattern matches the corresponding path part 
                foreach part $parts url_part $url_parts {
                    if {[qc::url_decode $url_part] eq $part} {
                        lappend url_pattern_parts $part
                    } elseif {[string first : $part] == 0 } {
                        # the first character of the pattern part was ':'
                        lappend url_pattern_parts $part
                    }
                }

                # check if the built url_pattern_parts is the same as the handler
                if {[join $url_pattern_parts /] eq $handler} {
                    return true
                }        
            }
            return false
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
        
        proc proc_name {pattern method} {
            #| Get the validation proc_name for the handler named "$method $pattern".
            return [qc::nsv_dict get handlers VALIDATE $method $pattern proc_name]
        }

        proc args {pattern method} {
            #| Get all arguments for the handler named "$method $pattern".
            return [qc::nsv_dict get handlers VALIDATE $method $pattern args]
        }

        proc default {pattern method arg} {
            #| Get the default value of the given arg for the handler named "$method $pattern".
            return [qc::nsv_dict get handlers VALIDATE $method $pattern defaults $arg]
        }

        proc default_exists {pattern method arg} {
            #| Check if a default argument exists for the given argument for handler named "$method $pattern".
            return [qc::nsv_dict exists handlers VALIDATE $method $pattern defaults $arg]
        }

        proc args_from_dict {dict pattern method} {
            #| Returns a list of args for the handler named "$method $pattern" that correspond to any form variables in the given dictionary
            set method [string toupper $method]
            set args [args $pattern $method]
            set handler_args {}
            foreach arg $args {
                if {[default_exists $pattern $method $arg]} {
                    # the argument was an optional one 
                    if {[dict exists $dict $arg]} {
                        lappend handler_args [dict get $dict $arg]
                    } elseif { [regexp {^[^.]+\.([^.]+)$} $arg -> column] && [dict exists $dict $column] } {
                        # Return the first form value matching a fully qualified handler arg
                        # eg. Use form var firstname for arg users.firstname
                        lappend handler_args [dict get $dict $column]
                    } else {
                        lappend handler_args [default $pattern $method $arg]
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