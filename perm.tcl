# Copyright (C) 2001-2006, Bernhard van Woerden <bernhard@qcode.co.uk>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# $Header: /home/bernhard/cvs/exf/tcl/qc::sales_order.tcl,v 1.13 2004/03/16 10:34:04 bernhard Exp $

proc qc::perm_get { perm_name property } {
    #| Abstraction layer for accessing properties
    set qry { select * from perm where perm_name=:perm_name }
    db_thread_cache_1row $qry
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

