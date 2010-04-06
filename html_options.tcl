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
# $Header: /home/bernhard/cvs/exf/tcl/qc::options.tcl,v 1.15 2003/11/23 12:16:00 bernhard Exp $

proc qc::html_options_db { qry } {
    #| Expects a qry use columns named "name" and "value"
    #| Use aliases where required.
    #| E.g select foo_id as value,description as name from foo
    set options {}
    db_thread_cache_foreach $qry {
	lappend options $name $value
    }
    return $options
}

proc qc::html_options_db_cache { qry {ttl 86400}} {
    #| Expects a qry use columns named "name" and "value"
    #| Use aliases where required.
    #| E.g select foo_id as value,description as name from foo
    #| Query results are cached 
    set options {}
    db_cache_foreach $ttl $qry {
	lappend options $name $value
    }
    return $options
}

proc qc::html_options_simple { args } {
    #| Use list items as both name and value
    #| Eg Converts one two three -> one one two two three three
    if { [llength $args]==1 } {set args [lindex $args 0]}
    set options {}
    foreach item $args {
        lappend options $item $item
    }
    return $options
}
