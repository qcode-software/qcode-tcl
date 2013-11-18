package provide qcode 2.0
package require doc
namespace eval qc {
    namespace export form_var_* form2* form_proc
}

proc qc::form_var_names {} {
    #| Return a list of form variable names
    return [ns_set_keys [ns_getform]]
}

proc qc::form2vars {args}  {
    #| Create variables in the caller's namespace corresponding to the form data.
    if { [llength $args] == 0 } {
	# set all vars
	set args [ns_set_keys [ns_getform]]
    }
    # set vars
    foreach name $args {
	if { [form_var_exists $name] } {
	    upset 1 $name [form_var_get $name]
	}
    }
}

doc qc::form2vars {
    Description {
	Create variables in the caller's namespace corresponding to the form data. If a list of variable names is specified then only create variables in that list if corresponding form data exists;otherwise create variables for all the names in the form data.
	<p>
	Where a form variable appears many times return values as list
    }
    Usage {
	form2vars ?varName? ?varName? ...
    }
    Examples {
	# some-page.html?firstname=Jimmy&surname=Tarbuck
	% form2vars firstname surname
	% set firstname
	Jimmy
	% set surname
	Tarbuck
	%
	# A repeated variable name will result in a list
	# some-page.html?foo=1&foo=3&foo=56&bar=34
	form2vars
	# form2vars called with no args sets all form variables
	set foo
	1 3 56
	set bar
	34
    }
}

proc qc::form_var_get { var_name } {
    #| If the form variable exists return its value otherwise throw an error.
    #| A repeated form variable will return a list of corresponding values.
    #| PHP style repeated form variables foo[]=1 foo[]=2 treated as a list.
    set set_id [ns_getform]
    if { [string equal $set_id ""] } {
	error "No such form variable \"$var_name\""
    }
    if { [ns_set find $set_id $var_name] != -1 } {
	if { [ns_set unique $set_id $var_name] } {
	    return [ns_set get $set_id $var_name]
	} else {
	    return [qc::ns_set_getall $set_id $var_name]
	}	
    }
    # Look for PHP style repeated form variables
    set array_name "${var_name}\[\]";
    if { [ns_set find $set_id $array_name] != -1 } {
	return [qc::ns_set_getall $set_id $array_name]
    }
    error "No such form variable \"$var_name\""
}

doc qc::form_var_get {
    Examples {
	# some-page.html?foo=2&foo=45&bar=Hello%20World
	% form_var_get foo
	2 45
	% form_var_get bar
	Hello World
	%
	% form_var baz
	No such form variable "baz"
	%
	# some-page.html?foo[]=a&foo[]=b
	% form_var_get foo
	a b
    }
}

proc qc::form_var_exists { var_name } {
    #| Test whether a form variable exists or not.
    # Also check for PHP style repeated variables foo[]=1 foo[]=2 using name foo
    if { [info commands ns_conn] eq "ns_conn"
	 && [ns_conn isconnected]
	 && [ne [set set_id [ns_getform]] ""]
	 && ( [ns_set find $set_id $var_name] != -1 || [ns_set find $set_id "${var_name}\[\]"] != -1 )
     } {
	return 1
    } else {
	return 0
    }
}

doc qc::form_var_exists {
    Examples {
	# some-page.html?foo=2&foo=45&bar=Hello%20World
	% form_var_exists foo
	1
	% form_var_exists baz
	0
    }
}

proc qc::form2dict {args}  {
    #| Create dict corresponding to the form data.
    set dict {}
    if { [llength $args] == 0 } {
	# set all vars
	set args [ns_set_keys [ns_getform]]
    }
    # set vars
    foreach name $args {
	if { [form_var_exists $name] } {
	    lappend dict $name [form_var_get $name]
	}
    }
    return $dict
}

proc qc::form2url { url } {
    #| Encode the names and values of a form in an url
    foreach {name value} [qc::ns_set_to_multimap [ns_getform]] {
	set url [url $url $name $value]
    }
    return $url
}

doc qc::form2url {
    Examples {
	# some-page.html?foo=2&foo=45&bar=Hello%20World
	form2url other-url.html
	other-url.html?foo=2&foo=45&bar=Hello%20World
    }
}

proc qc::form_proc { proc_name } {
    #| Call proc_name using corresponding form variables
    set largs {}
    if { [eq [lindex [info args $proc_name] end] args] } {
	set args [lrange [info args $proc_name] 0 end-1]
    } else {
	set args [info args $proc_name]
    }
    foreach arg $args {
	if { [qc::form_var_exists $arg] } {
	    lappend largs [qc::form_var_get $arg]
	} else {
	    if { [info default $proc_name $arg default_value] } {
		lappend largs $default_value
	    } else {
		error "The form variable \"$arg\" was missing from the request" {} USER
	    }
	}
    }
    if { [eq [lindex [info args $proc_name] end] args] } {
	lappend largs [qc::form2dict {*}[lexclude [ns_set_keys [ns_getform]] {*}[info args $proc_name]]]
    }
    return [uplevel 0 $proc_name $largs]
}

doc qc::form_proc {
    Description {
	Call proc_name using corresponding form variables
	if the last variable name is called args then it is filled with a dict containing name value
	pairs for the remaining form data.
	See <proc>conn_marshal</proc> for a way of using this.
    }
    Examples {
	# Lets say we have a proc called hello
	proc hello {name message} {
	    return_html "$name said $message"
	}
	# When handling a request for some-url.html?name=John&message=Hello%20World
	% form_proc hello
	John said Hello World
	# equivalent to
	% hello John "Hello World"
	John said Hello World
    }
}

