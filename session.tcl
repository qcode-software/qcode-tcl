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
# $Header: /home/bernhard/cvs/exf/tcl/qc::session.tcl,v 1.8 2004/03/16 10:34:04 bernhard Exp $

proc qc::session_new { employee_id } {
    #| Create a new session
    set now [ns_time]

    # set session_id [ns_sha1 "$now[ns_rand]$employee_id"]
    # cannot get nssha to compile under FreeBSD

    set session_id "${employee_id}${now}[ns_rand]"
    set ip [qc::conn_remote_ip]
    db_dml "insert into session [sql_insert session_id ip employee_id]"
    return $session_id
}

proc qc::session_update { session_id } {
    #| Update a session
    db_0or1row {select hit_count from session where session_id=:session_id} {
	error "Invalid Session $session_id"
    } {
	incr hit_count
	set ip [qc::conn_remote_ip]
	set time_modified [cast_timestamp now]
	db_dml "update session set [sql_set hit_count ip time_modified] where session_id=:session_id"
	return $session_id
    }
}

proc qc::session_kill {session_id} {
    db_dml "delete from session where session_id=:session_id"
}

proc qc::session_exists {session_id} {
    db_1row {select count(*) as count from session where session_id=:session_id}
    if { $count==1 } {
	return true
    } else {
	return false
    }
}

proc qc::session_employee_id {session_id} {
    db_1row {select coalesce(effective_employee_id,employee_id) from session where session_id=:session_id}
    return $employee_id
}

proc qc::session_sudo {session_id effective_employee_id} {
    db_dml {update session set effective_employee_id=:effective_employee_id where session_id=:session_id}
}

proc qc::session_purge { {timeout_secs 0 } } {
    #
    # Purge all sessions older than time_out_secs
    #
    ns_log Notice "session purge older than $timeout_secs secs"
    db_dml "delete from session where extract(seconds from current_timestamp-time_modified)>:timeout_secs"
}
