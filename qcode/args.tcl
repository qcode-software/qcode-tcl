package provide qcode 1.0
package require doc
namespace eval qc {}

doc Args {
    Title "Argument Passing in TCL"
    Description {
	<p>
	Arguments to a proc are just a list and TCL allows the use of the args argument to access a variable length list of arguments to the proc.<br>
	Different interpretations of the args list allows us to build different mechanisms for passing arguments
	</p>
	<ul>
	<li>Pass by Value</li>
	<li>Pass by Reference</li>
	<li>Pass by Name</li>
	<li>Pass by Dict</li>
	<li>Pass by Dict ~ Tilde Shorthand</li>
	
	</ul>
	
	<h3>Pass by Value - the standard TCL way</h3>
	<p>
	TCL procs pass values to procedures using an ordered sequence.<br>
	Assignment of values to the argument variables is made by matching the value to the corresponding variable in the sequence of arguments.
	</p>
	<example>
	# Pass by Value
	proc volume {radius length} {
	    return [expr 3.14*$radius*$radius*$length]
	}
	% set radius 2
	% set length 4
	% volume $radius $length
	50.24
	</example>

	<h3>Pass by Reference</h3>
	<p>
	Upvar can be used to reference a variable in the caller's namespace.<br>
	The local and callers variable names can be different but here they are both the same.
	<p>
	Using "pass by reference" should be avoided because changes in the local proc variable will affect the caller and can lead to some unexpected bugs. 
	
	</p>
	<example>
	# Pass by Reference
	proc volume {radiusVar lengthVar} {
	    upvar 1 $radiusVar radius
	    upvar 1 $lengthVar length
	    return [expr 3.14*$radius*$radius*$length]
	}
	% set radius 2
	% set length 4
	% volume radius length
	50.24
	</example>
	This technique can be generalised to handle any sequence of arguments.
	<example>
	proc volume {args} {
	    foreach varName $args {upvar 1 $varname $varName}
	    return [expr 3.14*$radius*$radius*$length]
	}
	% set radius 3
	% set length 4
	% volume radius length
	50.24
	</example>

	<h3>Pass by Name</h3>
	Here the local variables are initially set to hold the same value as 
	the caller's variables. 
	This technique ensures that changes to the local variable do not affect the caller.
	<example>
	# Pass by name
	proc volume {radiusVar lengthVar} {
	    set radius [uplevel 1 set $radiusVar]
	    set length [uplevel 1 set $lengthVar]
	    return [expr 3.14*$radius*$radius*$length]
	}
	% set radius 2
	% set length 4
	% volume radius length
	50.24
	</example>
	This technique can be generalised to handle any sequence of arguments.
	<example>
	proc volume {args} {
	    foreach varName $args {set $varName [uplevel 1 set $varName]}
	    return [expr 3.14*$radius*$radius*$length]
	}
	% set radius 3
	% set length 4
	% volume radius length
	50.24
	</example>
	<h3>Pass by Dict</h3>
	Pass by dict provides a way of passing "named arguments" where the sequence of the args does not matter.<br>
	For procs that take a long list of arguments it becomes convenient to pass a dict rather than remember the order of arguments.<br>
	It is also suitable for procs that have many optional arguments.
	<example>
	proc volume {dict} {
	    set radius [dict get $dict radius]
	    set length [dict get $dict length]
	    return [expr 3.14*$radius*$radius*$length]
	}
	% set radius 2
	% set length 4
	% volume [list radius $radius length $length]
	50.24
	</example>
	It is a pain having to construct the dict when calling this proc and it would be nice to be able to write
	<example>
	volume [list radius $radius length $length]
	or
	volume radius $radius length $length
	</example>
	To allow both methods to call the proc correctly I use 
	<example>
	if { [llength $args]==1 } {set args [lindex $args 0]}
	</example>
	which gives
	<example>
	proc volume {args} {
	    if { [llength $args]==1 } {set args [lindex $args 0]}
	    set radius [dict get $args radius]
	    set length [dict get $args length]
	    return [expr 3.14*$radius*$radius*$length]
	}
	% set radius 2
	% set length 4
	% volume [list radius $radius length $length]
	50.24
	% volume radius $radius length $length
	50.24
	</example>
	
	<h3>Pass by Dict ~ Tilde Shorthand</h3>
	<p>
	Instead of writing long lists of <i>name value name value name value ...</i> pairs we can create dict's from local variables using <proc>dict_from</proc>.<br>
	A qcode shorthand way of writing that uses a tilde ~ to indicate that the following list items are variable names rather than name-value pairs.
	The proc can use <proc>args2dict</proc> or <proc>args2vars</proc> to parse the argument list and interpret it as a dict or a list of variable names.<br>
	<example>
	proc volume {args} {
	    set dict [args2dict $args]
	    set radius [dict get $dict radius]
	    set length [dict get $dict length]
	    return [expr 3.14*$radius*$radius*$length]
	}
	% set radius 2
	% set length 4
	% volume radius $radius length $length
	50.24
	% volume [dict_from radius length]
	50.24 
	% volume ~ radius length
	50.24
	</example>
    }
}

proc qc::args2dict {callers_args} {
    #| Parse callers args. Interpret as regular dict unless first item is ~ 
    #| in which case interpret as a list of variable names to pass-by-name.
    #| Return dict of resulting name value pairs.

    if { [llength $callers_args]==1 } {set callers_args [lindex $callers_args 0]}
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

doc args2dict {
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

    if { [llength $args]==1 } {set args [lindex $args 0]}
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
	
	% test [list foo James bar Robert baz Desmond]
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


proc qc::arg_options_split {callers_args} {
    # Return two lists for options pairs and other args
    set options {}
    set others {}
    set index 0
    while {$index<[llength $callers_args]} {
	set name [lindex $callers_args $index]
	if { [eq $name "--"] } {
	    incr index
	    set others [lrange $callers_args $index end]
	    break
	} elseif { [eq [string index $name 0] "-"] } {
	    lappend options [string range $name 1 end] [lindex $callers_args [expr {$index+1}]]
	    incr index 2
	} else {
	    lappend others $name
	    incr index
	}
    }
    return [list $options $others]
}				    

proc qc::args_by_name2dict {args} {
    # Convert args list of mixed varNames and "option pairs" to a dict.
    if { [llength $args]==1 } {set args [lindex $args 0]}
    set index 0
    lassign [arg_options_split $args] dict varNames
    foreach varName $varNames { lappend dict $varName [upset 2 $varName] }
    return $dict
}				    

proc qc::args_by_name2vars {args} {
    # Set variables in caller's namespace using a mixed varNames and "option pairs" list of args
    if { [llength $args]==1 } {set args [lindex $args 0]}
    set index 0
    lassign [arg_options_split $args] options varNames
    foreach {name value} $options {upset 1 $name $value}
    foreach name $varNames {upset 1 $name [upset 2 $name]}
    #return a list of varNames that were set in caller's namespace
    return [concat [dict keys $options] $varNames]
}				    

proc qc::args_check_required {callers_args args} {
    # Assume callers_args is a dict of name value pairs
    # check that all the keys given exist.

    foreach arg $args {
	if { ![dict exists $callers_args $arg] } {
	    error "Missing value for arg \"$arg\" when calling \"[info level -1]\""
	}
    }
}

proc qc::args_split {callers_args {switch_names ""}} {
    # Return two lists for options pairs and other args
    set switches {}
    set options {}
    set others {}
    set index 0
    while {$index<[llength $callers_args]} {
	set arg [lindex $callers_args $index]
	set next [lindex $callers_args [expr {$index+1}]]
	if { [eq $arg "--"] } {
	    incr index
	    set others [lrange $callers_args $index end]
	    break
	} elseif { [eq [string index $arg 0] "-"] \
		       && ([eq [string index $next 0] "-"] \
				|| [in $switch_names [string range $arg 1 end]] \
				|| [in $switch_names $arg] \
				)} {
	    # switch
	    lappend switches [string range $arg 1 end]
	    incr index 1
	} elseif { [eq [string index $arg 0] "-"] && [ne [string index $next 0] "-"] } {
	    # option
	    lappend options [string range $arg 1 end] $next 
	    incr index 2
	} else {
	    # other
	    lappend others $arg
	    incr index
	}
    }
    return [list $switches $options $others]
}	

proc qc::args {callers_args args} {
    lassign [args_split $args] switches options others
    lassign [args_split $callers_args $switches] callers_switches callers_options callers_others

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
	if { [llength [lexclude $callers_switches {*}$switches]]>0 } {
	    # Usage Error - unknown switches
	    error "Unknown switches [lexclude $callers_switches {*}$switches]"
	}
	foreach switch $callers_switches {
	    upset 1 $switch true
	}
	# Options
	foreach {name value} $callers_options {
	    if { ![dict exists $options $name] } {
		error "Illegal option \"$name\""
	    }
	}
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