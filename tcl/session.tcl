namespace eval qc {
    namespace export session_*
}

package require uuid
proc qc::session_new { user_id } {
    #| Create a new session
    # Grab some random entropy
    set file [open /dev/urandom]
    fconfigure $file -translation binary
    set entropy1 [read $file 50]
    set entropy2 [read $file 50]
    close $file
    set uuid [uuid::uuid generate]
    set session_id [qc::sha1 "$uuid $entropy1"]
    set authenticity_token [qc::sha1 $entropy2]
    if { [qc::conn_open]} {
        set ip [qc::conn_remote_ip]
    } else {
        set ip ""
    }
    db_dml "insert into session [sql_insert session_id ip user_id authenticity_token]"    
    return $session_id
}

proc qc::session_authenticity_token {session_id} {
    #| Return the authenticity token
    db_1row {select authenticity_token from session where session_id=:session_id}
    return $authenticity_token
}

proc qc::session_update { session_id } {
    #| Update a session
    db_0or1row {select hit_count from session where session_id=:session_id} {
	return -code error -errorcode USER "Invalid Session $session_id"
    } {
	incr hit_count
	set ip [qc::conn_remote_ip]
	set time_modified [cast_timestamp now]
	db_dml "update session set [sql_set hit_count ip time_modified] where session_id=:session_id"
	return $session_id
    }
}

proc qc::session_sudo_logout {session_id} {
    #| Go back to using own id
    db_dml {update session set effective_user_id=NULL where session_id=:session_id}
    global current_user_id
    if { [info exists current_user_id] } {
        unset current_user_id
    }
}

proc qc::session_kill {session_id} {
    #| Kill a session
    db_dml "delete from session where session_id=:session_id"
}

proc qc::session_exists {session_id} {
    #| Test if a session exists
    db_1row {select count(*) as count from session where session_id=:session_id}
    if { $count==1 } {
	return true
    } else {
	return false
    }
}

proc qc::session_valid {args} {
    #| Check session exists and has not expired.
    qc::args $args -age_limit "12 hours" -idle_timeout "1 hour" -- session_id
    set qry {
	select
	user_id
	from session
	where
	session_id=:session_id
	and (current_timestamp-time_modified) <=:idle_timeout::interval
        and (current_timestamp-time_created) <=:age_limit::interval
    }
    db_0or1row $qry {
	return false
    } {
	return true
    }
}

proc qc::session_user_id {session_id} {
    #| Return the user_id owner of this session
    db_1row {select coalesce(effective_user_id,user_id) as user_id from session where session_id=:session_id}
    return $user_id
}

proc qc::session_sudo {session_id effective_user_id} {
    #| Sudo enables a user to use the priviliges of another user.
    db_dml {update session set effective_user_id=:effective_user_id where session_id=:session_id}
    global current_user_id
    set current_user_id $effective_user_id
}

proc qc::session_purge { {timeout_secs 0 } } {
    #| Purge all sessions older than time_out_secs
    log Notice "session purge older than $timeout_secs secs"
    db_dml "delete from session where extract(seconds from current_timestamp-time_modified)>:timeout_secs"
}

proc qc::session_id {} {
    #| Return the current user's session_id
    global session_id
    if { [info exists session_id] } {
        return $session_id
    }
    if { [cookie_exists session_id] } {
        return [set session_id [cookie_get session_id]]
    }
    return -code error "No known session_id"
}

