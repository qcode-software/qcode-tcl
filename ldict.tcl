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
# $Header: /var/lib/cvs/exf/tcl/qc::ldict.tcl,v 1.4 2003/03/01 18:14:49 nsadmin Exp $

proc qc::ldict_set {ldictVar index key value} {
    upvar 1 $ldictVar ldict
    set dict [lindex $ldict $index]
    dict set dict $key $value
    lset ldict $index $dict
}

proc qc::ldict_sum { ldictVar key } {
    set sum 0
    upvar 1 $ldictVar ldict
    foreach dict $ldict {
	set value [dict get $dict $key]
	set value [ns_striphtml $value]
	regsub -all {[, ]} $value {} value
	if { [string is double -strict $value] } {
	    set sum [expr {$sum + $value}]
	}
    }
    return $sum
}

proc qc::ldict_max { ldictVar key } {
    set max {}
    upvar 1 $ldictVar ldict
    foreach dict $ldict {
	set value [dict get $dict $key]
	if { [string equal $max ""] } {
	    set max $value
	} else {
	    if { $value > $max } {
		set max $value
	    }
	}
    }
    return $max
}

proc qc::ldict_values { ldictVar key } {
    # Return a list of the values of this key
    # in each dict in the ldict
    upvar 1 $ldictVar ldict
    set list {}
    foreach dict $ldict {
	lappend list [dict get $dict $key]
    }
    return $list
}

proc qc::ldict_search {ldictVar key value} {
    # Return the first index of the dict that contains the value $value for the key $key
    upvar 1 $ldictVar ldict
    set index 0
    foreach dict $ldict {
	if { [dict exists $dict $key] && [dict get $dict $key]=="$value" } {
	    return $index
	}
	incr index
    }
    return -1
}

proc qc::ldict_exclude { ldict key } {
    set newldict {}
    foreach dict $ldict {
	lappend newldict [dict_exclude $dict $key]
    }
    return $newldict
}

proc qc::ldict2tbody {ldict colnames} {
    # take a ldict and a list of col names to convert into tbody
    set tbody {}
    foreach dict $ldict {
	set row {}
	foreach colname $colnames {
	    if { [dict exists $dict $colname] } {
		lappend row [dict get $dict $colname]
	    } else {
		lappend row ""
	    }
	}
	lappend tbody $row
    }
    return $tbody
}