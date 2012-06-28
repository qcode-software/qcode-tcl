package provide qcode 1.6
package require doc
namespace eval qc {}

proc qc::session_new { employee_id } {
    #| Create a new session
    set now [qc::cast_epoch now]

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

proc qc::session_sudo_logout {session_id} {
    db_dml {update session set effective_employee_id=NULL where session_id=:session_id}
    global current_employee_id
    if { [info exists current_employee_id] } {
	unset current_employee_id
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
    db_1row {select coalesce(effective_employee_id,employee_id) as employee_id from session where session_id=:session_id}
    return $employee_id
}

proc qc::session_sudo {session_id effective_employee_id} {
    db_dml {update session set effective_employee_id=:effective_employee_id where session_id=:session_id}
    global current_employee_id
    set current_employee_id $effective_employee_id
}

proc qc::session_purge { {timeout_secs 0 } } {
    #
    # Purge all sessions older than time_out_secs
    #
    log Notice "session purge older than $timeout_secs secs"
    db_dml "delete from session where extract(seconds from current_timestamp-time_modified)>:timeout_secs"
}
