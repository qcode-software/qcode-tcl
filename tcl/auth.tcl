namespace eval qc {
    namespace export auth auth_check auth_hba auth_hba_check auth_session
}

proc qc::auth {} {
    #| Try to authenticate the current user
    #| If successful cache the result in global
    #| On failure throw AUTH error
    global current_user_id
    if { [info exists current_user_id] } {
        return $current_user_id
    }
    
    # Try session based auth
    if { [info exists ::session_id] || [qc::cookie_exists session_id] } {
        set session_id [qc::session_id]
        if { [qc::session_exists $session_id] } {
            set current_user_id [qc::auth_session $session_id]
            qc::session_update $session_id
            return $current_user_id
        }
    }
    
    # HBA
    if { [qc::auth_hba_check] } {
        return [set current_user_id [qc::auth_hba]]
    }
    
    error "Cannot authenticate you using either session_id or ip address. Please log in." {} AUTH
}

proc qc::auth_check {} {
    #| Check if we can authenticate the user
    #| Return true or false
    # session based auth
    if { [qc::cookie_exists session_id]} {
	set session_id [cookie_get session_id]
	if { [qc::session_exists $session_id] } {
	    return true
	}
    }
    
    # HBA
    if { [qc::auth_hba_check] } {
	return true
    }
    
    return false
}

proc qc::auth_hba {} {
    #| Try to authenticate who the current user is
    #| based on ip address
    #| On failure throw AUTH error
    set ip [qc::conn_remote_ip]
    set qry "select user_id as user_id from users where ip=:ip"
    db_cache_0or1row $qry { 
	error "Cannot authenticate user on ip $ip" {} AUTH
    } { 
	return $user_id
    } 
}

proc qc::auth_hba_check {} {
    #| Check if the current user can be authenticated
    #| based on ip address
    set ip [qc::conn_remote_ip]
    set qry "select user_id from users where ip=:ip"
    db_cache_0or1row $qry { 
	return false
    } { 
	return true
    } 
}

proc qc::auth_session { session_id} {
    #| Try to authenticate user based on the session_id given
    #| Return the user_id if successful
    #| On failure throw AUTH error
    if { [session_valid $session_id] } {
        return [session_user_id $session_id]
    } else {
	error "Session authentication failed to identify you." {} AUTH
    }
}

