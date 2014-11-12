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

