package provide qcode 2.4.0
package require doc
namespace eval qc {
    namespace export args2dict args2vars args_check_required args_definition_split args_split args
}

doc Args {
    Title "Argument Passing in TCL"
    Url {/qc/wiki/ArgPassing}
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
	return $callers_args
    }
}

doc qc::args2dict {
    Parent Args
    Description {
	Parse callers args. Interpret as regular dict unless first item is ~ in which case interpret as a list of variable names to pass-by-name.
	Return dict of resulting name value pairs.
    }
    Usage {args2dict args}
    Examples {
	% set foo Jimmy
	% set bar Bob
	% set baz Des
	%
	% proc test {args} {
	    return [args2dict $args]
	  }
	%
	% test foo James bar Robert baz Desmond
	foo James bar Robert baz Desmond
	
	% test [list foo James bar Robert baz Desmond]
	foo James bar Robert baz Desmond

	% test ~ foo bar baz
	foo James bar Robert baz Desmond
    }
}

proc qc::args2vars {callers_args args} {
    #| Parse callers args. Interpret as regular dict unless first item is ~ 
    #| in which case interpret as a list of variable names to pass-by-name.
    #| Dict - set all variables or just those specified that exists in the dict
    #| Pass-by-Value - set all variables or just those specified that exists in caller's namespce.

    if { [llength $callers_args]==1 } {set callers_args [lindex $callers_args 0]}
    set varNames {}

    if { [eq [lindex $callers_args 0] ~] } {
	# Pass by Name
	foreach varName [lrange $callers_args 1 end] {
	    if { [uplevel 2 info exists $varName] && ([llength $args]==0 || [in $args $varName]) } {
		upset 1 $varName [upset 2 $varName]
		lappend varNames $varName
	    }
	}
    } else {
	foreach {varName varValue} $callers_args {
	    if { [llength $args]==0 || [in $args $varName] } {
		upset 1 $varName $varValue
		lappend varNames $varName
	    }
	}
    }
    return $varNames
}

doc qc::args2vars {
    Parent Args
    Description {
	Parse callers args. Interpret as regular dict unless first item is ~ in which case interpret as a list of variable names to pass-by-name.
	Set all variables or just those specified.
	Ignore variable names that do not exists in the dict or do not exists in the caller's namespace.
    }
    Usage {args2vars args ?variableName? ?variableName? ...}
    Examples {
	% set foo Jimmy
	% set bar Bob
	% set baz Des
	%
	% proc test {args} {
	    set varNames [args2vars $args]
	    return "foo $foo bar $bar baz $baz"
	  }
	%
	% test foo James bar Robert baz Desmond
	foo James bar Robert baz Desmond
	
	% test {*}[list foo James bar Robert baz Desmond]
	foo James bar Robert baz Desmond

	% test ~ foo bar baz
	foo James bar Robert baz Desmond
	%
	% 
	% proc test {args} {
	    # name foo and bar as the only variables to set
	    set varNames [args2vars $args foo bar]
	    return "foo $foo bar $bar"
	  }
	%
	% test foo James bar Robert baz Desmond
	foo James bar Robert
	%
	% test ~ foo bar baz
	foo James bar Robert
    }
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

doc qc::args {
    Parent Args
    Description {
        Specify the caller args to expect, then parse and assign them to variables appropriately.
        Arguments can be specified as switches, options or standard Tcl procedure arguments.

        For switches, a switch is specifed in the args_spec using "-switch_name".
        If a switch is passed by the caller, args will set the variable of that name to true if the switch is present.
        By default, if not passed, the switch variable will be undefined. (The Qcode qc::default command can be used
        to set a default value).

        For options, an option is specified in the args_spec using "-option_name default"
        If option is passed by the caller, a default value can be specified. To indicate not default is required, 
        use "-option_name ?". If a default is not specified, the option variable will be undefined. Otherwise the
        variable "option_name" is assigned to the option value.

        If switches and/or options are to be called, they must be provided before any standard arguments, but can
        otherwise be called in any order regardless of the order in which they were defined. 
        To indicate the list of options and switches is finished use --
        e.g. "-foo -bar bar_default -baz baz_default --"

        The values appearing after -- (or if no options or switches were specified) are treated as standard Tcl 
        procedure arguments.
    }
    Usage {args caller_args specified_arguments}
    Examples {

	% proc options_test {args} {
	    qc::args $args -foo ? -bar 0 --
            # If called without any options, foo will be undefined, and bar will be 0.
            if { [info exists foo] } {
                return "foo $foo bar $bar"
            } else {
                return "foo UNDEF bar $bar"
            }
	  }
	
        % options_test
        foo UNDEF bar 0

	% options_test -foo 999 -bar 999
        foo 999 bar 999

	% proc switch_test {args} {
	    qc::args $args -foo --
            # If called without any options, both will be undefined unless a default is manually set as in this case.
            qc::default foo false
            return "foo is $foo"
	}

        % switch_test
        foo is false

        % switch_test -foo
        foo is true

        % proc test {args} {
            qc::args $args -foo -bar bar_default -- thud grunt
            qc::default foo false
            return "foo $foo bar $bar thud $thud grunt $grunt"
        }

        % test -bar 999 -foo quux quuux
        foo true bar 999 thud quux grunt quuux

        % test quux quuux
        foo false bar bar_default thud quux grunt quuux

        % test quux 
        Too few values

        % test quux quuux quuuux
        Too many values; expected 2 but got 3 in "quux quuux quuuux"
        
        % test quux quuux -baz 999
        Illegal option "baz"
    }
}




