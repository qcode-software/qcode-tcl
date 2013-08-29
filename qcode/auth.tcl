package provide qcode 2.0
package require doc
namespace eval qc {}

doc authentication {
    Title Authentication
    Url {/qc/wiki/AuthPage}
}

proc qc::auth {} {
    #| Try to authenticate the current employee/user
    #| If successful cache the result in global
    #| On failure throw AUTH error
    global current_employee_id
    if { [info exists current_employee_id] } {
	return $current_employee_id
    }
    # Try session based auth
    if { [cookie_exists session_id] } {
	set session_id [cookie_get session_id]
	if { [qc::session_exists $session_id] } {
	    qc::session_update $session_id
	    return [set current_employee_id [qc::auth_session $session_id]]
	}
    }
    # HBA
    if { [qc::auth_hba_check] } {
	return [set current_employee_id [qc::auth_hba]]
    }
    
    error "Cannot authenticate you using either session_id or ip address. Please log in." {} AUTH
}

doc qc::auth {
    Parent authentication
    Examples {
	% set employee_id [auth]
	23
    }
}

proc qc::auth_check {} {
    #| Check if we can authenticate the employee
    #| Return true or false
    # session based auth
    if { [cookie_exists session_id]} {
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

doc qc::auth_check {
    Parent authentication
}

proc qc::auth_hba {} {
    #| Try to authenticate who the current employee is
    #| based on ip address
    #| On failure throw AUTH error
    set ip [qc::conn_remote_ip]
    set qry "select employee_id from employee where ip=:ip"
    db_cache_0or1row $qry { 
	error "Cannot authenticate user on ip $ip" {} AUTH
    } { 
	return $employee_id
    } 
}

doc qc::auth_hba {
    Parent authentication
}

proc qc::auth_hba_check {} {
    #| Check if the current user can be authenticated
    #| based on ip address
    set ip [qc::conn_remote_ip]

    set qry "select employee_id from employee where ip=:ip"
    db_cache_0or1row $qry { 
	return false
    } { 
	return true
    } 
}

doc qc::auth_hba_check {
    Parent authentication
}

proc qc::auth_password { employee_code password } {
    #| Try to authenticate an employee based on employee_code and password
    #| On failure throw AUTH error
    set qry {
        select 
        employee_id 
        from employee 
        where 
        upper(employee_code)=upper(:employee_code) 
        and password_hash in (
                              crypt(:password,password_hash),  
                              crypt(invert_case(:password),password_hash)
                              )
    }
    db_cache_0or1row $qry {
	error "Password authentication failed" {} AUTH
    } { 
	return $employee_id
    }
}

doc qc::auth_password {
    Parent authentication
}

proc qc::auth_password_check { employee_code password } {
    #| Check if we can authenticate an employee based on employee_code and password
    set qry {
        select 
        employee_id 
        from employee 
        where 
        upper(employee_code)=upper(:employee_code) 
        and password_hash in (
                              crypt(:password,password_hash),  
                              crypt(invert_case(:password),password_hash)
                              )
    }
    db_cache_0or1row $qry {
	return false
    } { 
	return true
    }
}

doc qc::auth_password_check {
    Parent authentication
}

proc qc::auth_session { session_id } {
    #| Try to authenticate an employee based on the session_id given
    #| Return the employee_id if successful
    #| On failure throw AUTH error
    if { [session_exists $session_id] } {
	return [session_employee_id $session_id]
    } else {
	error "Session authentication failed to identify you." {} AUTH
    }
}

doc qc::auth_session {
    Parent authentication
}

