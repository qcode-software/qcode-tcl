package provide qcode 1.3
package require doc
namespace eval qc {}
doc authentication {
    Title Authentication
    Description {
	These procs try to authenticate who the current employee/user is.<br>
	<h3>Session</h3>
	Each session has a unique reference called the session_id that is very hard to guess. The user holds onto the session_id by way of a cookie which is passed to the server with each request.
	The proc <proc>session_exists</proc> can be used to test if the session is valid and <proc>auth_session</proc> can be used to return the employee_id of the session owner.
	<h3>Host Based Authentication</h3>
	Host based Authentication or HBA for short associates an employee with an IP address. If the remote user is using a particular IP address then we return the employee_id associated with that unique address. 
	<p>
	HBA is not suitable for hosts behind NAT unless you want to grant the same priviledges to all hosts behind the NAT router.Normally the server only sees the IP address of the NAT router.
	<p>
	The mapping of IP address to employee_id is stored in the employee table.<br>
	The proc <proc>auth_hba_check</proc> can be used to test if the user can be established based on IP address. The proc <proc>auth_hba</proc> can be used to return the employee_id associated with the IP address of the <link ref="conn_remote_ip">current connection</link> based on the employee table.
	<h3>Password Based Authentication</h3>
	Password based authentication checks a unique user identifier with a password. The unique identifier could be a username, employee code or email address. In this implementation it is an employee code.
	The proc <proc>auth_password_check</proc> can be used to test if the pair of values is valid and <proc>auth_password</proc> can be used to return the employee_id associated with this pair of values from the employee table.
	<h3>General</h3>
	The proc <proc>auth_check</proc> tries to establish if we can authenticate who the current user/employee is by checking session based authentication first and then host based authentication.
	<p> 
	The proc <proc>auth</proc> returns the employee_id of the current user by checking session based authentication first and then host based authentication. 
    }
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

doc auth {
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

doc auth_check {
    Parent authentication
}

proc qc::auth_hba {} {
    #| Try to authenticate who the current employee is
    #| based on ip address
    #| On failure throw AUTH error
    set ip [qc::conn_remote_ip]
    set qry "select employee_id from employee where ip=:ip"
    db_thread_cache_0or1row $qry { 
	error "Cannot authenticate user on ip $ip" {} AUTH
    } { 
	return $employee_id
    } 
}

doc auth_hba {
    Parent authentication
}

proc qc::auth_hba_check {} {
    #| Check if the current user can be authenticated
    #| based on ip address
    set ip [qc::conn_remote_ip]

    set qry "select employee_id from employee where ip=:ip"
    db_thread_cache_0or1row $qry { 
	return false
    } { 
	return true
    } 
}

doc auth_hba_check {
    Parent authentication
}

proc qc::auth_password { employee_code password } {
    #| Try to authenticate an employee based on employee_code and password
    #| On failure throw AUTH error
    set qry {select employee_id from employee where upper(employee_code)=upper(:employee_code) and upper(password)=upper(:password::text) }
    db_thread_cache_0or1row $qry {
	error "Password authentication failed" {} AUTH
    } { 
	return $employee_id
    }
}

doc auth_password {
    Parent authentication
}

proc qc::auth_password_check { employee_code password } {
    #| Check if we can authenticate an employee based on employee_code and password
    set qry {select employee_id from employee where upper(employee_code)=upper(:employee_code) and upper(password)=upper(:password::text) }
    db_thread_cache_0or1row $qry {
	return false
    } { 
	return true
    }
}

doc auth_password_check {
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

doc auth_session {
    Parent authentication
}

