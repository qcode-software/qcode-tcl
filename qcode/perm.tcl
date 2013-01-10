package provide qcode 1.11
package require doc
namespace eval qc {}

proc qc::perm_get { perm_name property } {
    #| Abstraction layer for accessing properties
    set qry { select * from perm where perm_name=:perm_name }
    db_cache_1row $qry
    return [set $property]
}

proc qc::perm { perm_name method } {
    #| Test whether the current user can perform $method on $perm_name
    #| Throws an error on failure.
    if { [string is false [perm_test $perm_name $method]] } {
	error "You do not have $method permission on $perm_name." {} PERM
    }
}

proc qc::perm_test { perm_name method } {
    #| Test whether the current user can perform $method on $perm_name
    #| Returns boolean
    set m [perm_method_abbrev $method]
    set employee_id [qc::auth]
    set perm_string [perm_get $perm_name perm_string]
    return [perm_string_test $employee_id $m $perm_string]
}

proc qc::perm_if {perm_name method if_code {. else} {else_code ""} } {
    #| Evaluate if_code if current user has permission else else_code
    if { [perm_test $perm_name $method] } {
	uplevel 1 $if_code
    } elseif {[ne $else_code ""]} {
	uplevel 1 $else_code
    }
}

proc qc::perm_test_employee { employee_id perm_name method } {
    #| Test whether the user can perform $method on $perm_name
    #| Returns boolean
    set m [perm_method_abbrev $method]
    set perm_string [perm_get $perm_name perm_string]
    return [perm_string_test $employee_id $m $perm_string]
}

proc qc::perm_string_test { employee_id m perm_string } {
    #| tests for method $m using all parties listed in $parties
    #| against the list of permissions in $perm_list
    #| return boolean 1 when permission is granted
    if { [dict exists $perm_string $employee_id] && [string first $m [dict get $perm_string $employee_id]]!=-1 } {
	return 1
    } else {
	return 0
    }
}

proc qc::perm_method_abbrev { method } {
    #| Return the single letter abbreviation for $method
    switch -glob -- $method {
	append { return a }
	read { return r }
	write { return w }
    }
    error "Unknown permission type $method"
}

proc qc::perm_method_long { m } {
    #| Return long name for single letter abbreviation
    switch $m {
	a { return create }
	r { return view }
	w { return edit }
    }
    error "Unknown permission type $m"
}

proc qc::perm_method_description { m } {
    #| Return a simple description of the method
    switch $m {
	a { return Create }
	r { return View }
	w { return Edit }
    }
    error "Unknown permission type $m"
}

proc qc::perm_string_add { perm_string employee_id m } {
    #| Add method $m for $employee_id to $perm_string
    #| and return new perm_string
    if { [dict exists $perm_string $employee_id] } {
	set methods [dict get $perm_string $employee_id]
	if { [string first $m $methods]==-1 } {
	    # Add the method
	    dict set perm_string $employee_id "${methods}$m"
	}
    } else {
	lappend perm_string $employee_id $m
    }
    return $perm_string
}

proc qc::perm_string_remove { perm_string employee_id m } {
    #| Remove method $m for $employee_id to $perm_string
    #| and return new perm_string
    if { [dict exists $perm_string $employee_id] } {
	set methods [dict get $perm_string $employee_id]
	if { [string first $m $methods]!=-1 } {
	    # Remove the method
	    if { [string length $methods]==1 } {
		dict unset perm_string $employee_id
	    } else {
		dict set perm_string $employee_id [regsub $m $methods {}]
	    }
	}
    }
    return $perm_string
}

