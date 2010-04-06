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
# $Header: /var/lib/cvs/exf/tcl/qc::dict.tcl,v 1.4 2003/03/01 18:14:49 nsadmin Exp $

if {![llength [info commands dict]]} {
    proc dict {cmd args} {
	uplevel 1 [linsert $args 0 qc::dict_$cmd]
    }
}

proc qc::dict_create { args } {
    if { [llength $args]==1 } {set args [lindex $args 0]}
    set dict {}
    foreach {name value} $args {
	dict_set dict $name $value
    }
    return $dict
    #array set array $args
    #return [array get array]
}

proc qc::dict_get { dict key } {
    set index [lsearch -exact $dict $key]
    while { $index%2!=0 && $index!=-1 && $index<[llength $dict]} {
	incr index
	set index [lsearch -exact -start $index $dict $key]
    }
    if { $index%2 == 0 } {
	return [lindex $dict [expr {$index+1}]]
    } else {
	error "dict does not contain the key:$key it contains \"$dict\""
    } 
}

proc qc::dict_set { dictVariable key value } {
    upvar 1 $dictVariable dict
    if { [info exists dict] } {
	set index [lsearch -exact $dict $key]
    } else {
	set index -1
    }
    if { $index%2 == 0 } {
	lset dict [expr {$index+1}] $value
    } else {
	lappend dict $key $value
    }
}

proc qc::dict_unset { dictVariable key } {
    upvar 1 $dictVariable dict
    set index [lsearch -exact $dict $key]
    if { $index%2 == 0 } {
	set dict [lreplace $dict $index [expr {$index+1}]]
    }
}

proc qc::dict_exists { dict key } {
    # Check if a value exists for this key
    set index [lsearch -exact $dict $key]
    while { $index%2!=0 && $index!=-1 && $index<[llength $dict]} {
	incr index
	set index [lsearch -exact -start $index $dict $key]
    }
    if { $index%2 == 0 } {
	return 1
    } else {
	return 0
    } 
}

proc qc::dict_incr {dictVariable key {value 1}} {
    # Incr a dict value
    upvar 1 $dictVariable dict
    dict_set dict $key [expr {[dict_get $dict $key]+$value}]
}

proc qc::dict_lappend {dictVariable key args} {
    # Incr a dict value
    upvar 1 $dictVariable dict
    if { [dict_exists $dict $key] } {
	set list [dict_get $dict $key] 
	dict_set dict $key [lappend list $args]
    } else {
	dict_set dict $key $args
    }
}

proc qc::dict_keys {dict} {
    set keys {}
    foreach {key value} $dict {
	lappend keys $key
    }
    return $keys
}

proc qc::dict_subset {dict args} {
    # Return an dict made up of the keys given
    if { [llength $args]==1 } {set args [lindex $args 0]}
    set result {}
    foreach key $args {
	if { [dict exists $dict $key] } {
	    lappend result $key [dict get $dict $key]
	}
    }
    return $result
}

proc qc::dict_exclude {dict args} {
    #return an dict excluding keys given
    if { [llength $args]==1 } {set args [lindex $args 0]}
    set temp {}
    foreach {key value} $dict {
	if { ![in $args $key] } {
	    lappend temp $key $value
	}
    }
    return $temp
}

proc qc::dict_sort {dictVariable} {
    upvar 1 $dictVariable dict
    set llist {}
    foreach {name value} $dict {
	lappend llist [list $name $value]
    }
    set llist [lsort -index 1 $llist]
    set dict {}
    foreach item $llist {
	lappend dict [lindex $item 0] [lindex $item 1] 
    }
    return $dict
}
    
proc qc::dict2xml { args } {
    if { [llength $args]==1 } {set args [lindex $args 0]}
    set list {}
    foreach {name value} $args {
        lappend list [qc::xml $name $value]
    }
    return [join $list \n]
}

proc qc::dict_from { args } {
    # Take a list of var names and return a dict
    if { [llength $args]==1 } {set args [lindex $args 0]}
    
    set dict {}
    foreach name $args {
	upvar 1 $name value
	if { [info exists value] } {
	    lappend dict $name $value
	} else {
	    error "Can't create dict with $name: No such variable"
	}
    }
    return $dict
}

proc qc::dict2vars { dict args } {
    if { [llength $args]==1 } {set args [lindex $args 0]}
    
    if { [llength $args]==0 } {
	# set all variables
	foreach {name value} $dict {upset 1 $name $value}
    } else {
	# only set named variables
	foreach name $args {
	    if { [dict exists $dict $name] } {
		upset 1 $name [dict get $dict $name]
	    } else {
		if { [uplevel 1 [list info exists $name]] } {
		    uplevel 1 [list unset $name]
		}
	    }
	}
    }
}
