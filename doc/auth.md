Title: Authentication
CSS: default.css

# Authentication
part of [Qcode Documentation](../index.html)

* * *

These procs try to authenticate who the current employee/user is.

## Session

Each session has a unique reference called the `session_id` that is very hard to guess. The user holds onto the session_id by way of a cookie which is passed to the server with each request.
The proc [`session_exists`] can be used to test if the session is valid and [auth_session] can be used to return the `employee_id` of the session owner.


## Host Based Authentication

Host based Authentication or HBA for short associates an employee with an IP address. If the remote user is using a particular IP address then we return the `employee_id` associated with that unique address. 

HBA is not suitable for hosts behind NAT unless you want to grant the same priviledges to all hosts behind the NAT router.Normally the server only sees the IP address of the NAT router.

The mapping of IP address to employee_id is stored in the employee table.
The proc [auth_hba_check] can be used to test if the user can be established based on IP address. The proc [auth_hba] can be used to return the `employee_id` associated with the IP address of the [current connection][conn_remote_ip] based on the employee table.


## Password Based Authentication

Password based authentication checks a unique user identifier with a password. The unique identifier could be a username, employee code or email address. In this implementation it is an employee code.
The proc [auth_password_check] can be used to test if the pair of values is valid and [auth_password] can be used to return the `employee_id` associated with this pair of values from the employee table.


## General

The proc [auth_check] tries to establish if we can authenticate who the current user/employee is by checking session based authentication first and then host based authentication.
 
The proc [auth] returns the `employee_id` of the current user by checking session based authentication first and then host based authentication. 

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[session_exists]: qc/session_exists.html

[auth_session]: qc/auth_session.html

[auth_hba]: qc/auth_hba.html
[auth_hba_check]: qc/auth_hba_check.html

[auth_password]: qc/auth_password.html
[auth_password_check]: qc/auth_password_check.html

[auth_check]: qc/auth_check.html
[auth]: qc/auth.html

[conn_remote_ip]: qc/conn_remote_ip.html

