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

proc qc::multimap_get_first { multimap key } {
    set index [lsearch $multimap $key]
    if { $index%2 == 0 } {
	return [lindex $multimap [expr {$index+1}]]
    } else {
	error "multimap does not contain the key:$key it contains \"$multimap\""
    }
}

proc qc::multimap_set_first { multimapVariable key value } {
    upvar 1 $multimapVariable multimap
    set index [lsearch $multimap $key]
    if { $index%2 == 0 } {
	lset multimap [expr {$index+1}] $value
    } else {
	lappend multimap $key $value
    }
}

proc qc::multimap_unset_first { multimapVariable key } {
    upvar 1 $multimapVariable multimap
    set index [lsearch $multimap $key]
    if { $index%2 == 0 } {
	set multimap [lreplace $multimap $index [expr {$index+1}]]
    }
}

proc qc::multimap_exists { multimap key } {
    # Check if a value exists for this key
    if { [lsearch $multimap $key]%2 == 0} {
	return 1
    } else {
	return 0
    }
}

proc qc::multimap_keys {multimap} {
    set keys {}
    foreach {key value} $multimap {
	lappend keys $key
    }
    return $keys
}
