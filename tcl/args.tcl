namespace eval qc {
    namespace export args2dict args2vars args_check_required args_definition_split args_split args
}

proc qc::args2dict {callers_args} {
    #| Parse callers args. Interpret as regular dict unless first item is ~ 
    #| in which case interpret as a list of variable names to pass-by-name.
    #| Return dict of resulting name value pairs.

    ### This line below has got to go but will break things. ####
    if { [llength $callers_args]==1 } {set callers_args [lindex $callers_args 0]}
    ##################
    if { [eq [lindex $callers_args 0] ~] } {
	# Pass by Name
	set dict {}
	foreach varName [lrange $callers_args 1 end] {
	    if { [uplevel 2 info exists $varName] } {
		lappend dict $varName [upset 2 $varName]
	    }
	}
	return $dict
    } else {
        if { [llength $callers_args] % 2 != 0 } {
            error "Missing name or value in args for qc::args2dict"
        }
        set dict [dict create {*}$callers_args]
        if { [llength $callers_args] ne [llength $dict] } {
            error "Duplicate key for qc::args2dict"
        }
	return $dict
    }
}

proc qc::args2vars {callers_args args} {
    #| Parse callers args. Interpret as regular dict unless first item is ~ 
    #| in which case interpret as a list of variable names to pass-by-name.
    #| Dict - set all variables or just those specified that exists in the dict
    #| Pass-by-Value - set all variables or just those specified that exists in caller's namespace.

    if { [llength $callers_args]==1 } {set callers_args [lindex $callers_args 0]}
    set varNames {}

    if { [eq [lindex $callers_args 0] ~] } {
	# Pass by Name
	foreach varName [lrange $callers_args 1 end] {
            # Check the varName for invalid characters
            if { [regexp {[^a-zA-Z0-9_-]} $varName] } {
                error "Variable names may only contain alphanumeric, underscore,\
                       and hyphen characters."
            }
            
	    if { [uplevel 2 info exists $varName] && ([llength $args]==0 || [in $args $varName]) } {
		upset 1 $varName [upset 2 $varName]
		lappend varNames $varName
	    }
	}
    } else {
	foreach {varName varValue} $callers_args {
            # Check the varName for invalid characters
            if { [regexp {[^a-zA-Z0-9_-]} $varName] } {
                error "Variable names may only contain alphanumeric, underscore,\
                       and hyphen characters."
            }
            
	    if { [llength $args]==0 || [in $args $varName] } {
		upset 1 $varName $varValue
		lappend varNames $varName
	    }
	}
    }
    return $varNames
}

proc qc::args_check_required {callers_args args} {
    #| Assume callers_args is a dict of name value pairs
    #| check that all the keys given exist.

    foreach arg $args {
	if { ![dict exists $callers_args $arg] } {
	    error "Missing value for arg \"$arg\" when calling \"[info level -1]\""
	}
    }
}

proc qc::args_definition_split {def_args} {
    #| Return three lists for switches, option-default pairs and other args
    set switches {}
    set options {}
    set others {}
    set index 0
    while {$index<[llength $def_args]} {
        set arg [lindex $def_args $index]
        set next [lindex $def_args [expr {$index+1}]]
        if { [eq $arg "--"] } {
            # -- indicates the end of switches and options, all remaining args are value arguments
            incr index 1
            set others [lrange $def_args $index end]
            break
        } elseif { [eq [string index $arg 0] "-"] && [eq [string index $next 0] "-"] } {
            # switch
            lappend switches [string range $arg 1 end]
            incr index 1
        } elseif { [eq [string index $arg 0] "-"] } {
            # option
            lappend options [string range $arg 1 end] $next 
            incr index 2
        } else {
            # value argument
            lappend others $arg
            incr index 1
        }
    }
    return [list $switches $options $others]
}

proc qc::args_split {caller_args switch_names option_names} {
    #| Return three lists for switches, options pairs and other args
    set caller_switches {}
    set caller_options {}
    set caller_others {}

    # If this proc takes switches/options and the first arg might be a switch or option
    if { [eq [string index [lindex $caller_args 0] 0] "-"] && ([llength $switch_names] > 0 || [llength $option_names] > 0) } {
        set index 0
        while {$index<[llength $caller_args]} {
            set arg [lindex $caller_args $index]
            set next [lindex $caller_args [expr {$index+1}]]
            if { [eq $arg "--"] } {
                # -- indicates the end of switches and options - all that remain are regular args
                incr index 1
                set caller_others [lrange $caller_args $index end]
                break
            } elseif { [eq [string index $arg 0] "-"] && [in $switch_names [string range $arg 1 end]] } {
                # switch
                lappend caller_switches [string range $arg 1 end]
                incr index 1
            } elseif { [eq [string index $arg 0] "-"] && [in $option_names [string range $arg 1 end]] } {
                # option
                lappend caller_options [string range $arg 1 end] $next 
                incr index 2
            } else {
                # Once a value argument has been found, all that remain must be value args
                set caller_others [lrange $caller_args $index end]
                incr index 1
                break
            }
        }
    } else {
        set caller_others $caller_args
    }
    return [list $caller_switches $caller_options $caller_others]
}

proc qc::args {callers_args args} {
    #| Assign caller arguments to variables as specified
    lassign [args_definition_split $args] switches options others
    lassign [args_split $callers_args $switches [dict keys $options]] callers_switches callers_options callers_others

    if { [llength $args]==0 } {
	foreach switch $callers_switches {
	    upset 1 $switch true
	}
	foreach {name value} $callers_options {
	     upset 1 $name $value
	}
	upset 1  args $callers_others
    } else {
	# prescribed
	# Usage Switches
	foreach switch $callers_switches {
	    upset 1 $switch true
	}
	# Options
	foreach {name defaultValue} $options {
	    if { [dict exists $callers_options $name] } {
		upset 1 $name [dict get $callers_options $name]
	    } elseif { [eq $defaultValue *] } {
		# Error - missing required option
		error "Missing required option for \"$name\""
	    } elseif { [eq $defaultValue ?] } {
		# Optional switch with no default
	    } else {
		# set default option value
		upset 1 $name $defaultValue
	    }
	}
	
	# Listed Arguments
	if { ![in $others args] && [llength $callers_others]>[llength $others] } {
	    # Usage Error - too many values
	    error "Too many values; expected [llength $others] but got [llength $callers_others] in \"$callers_args\""
	}
	
	set index 0
	foreach name $others {
	    if { [eq $name args] } {
		break 
	    } elseif { $index>([llength $callers_others]-1)} {
		if { [llength $name]==2 } {
		    # default value
		    upset 1 [lindex $name 0] [lindex $name 1]
		} else {
		    # Usage Error - too few values
		    error "Too few values"
		}
	    } else {
		upset 1 [lindex $name 0] [lindex $callers_others $index]
	    }
	    incr index
	}
	upset 1 args [lrange $callers_others $index end]
    }
}

