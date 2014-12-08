Authentication
======================
part of [Qcode Documentation](index.md)

* * *

These procs try to authenticate who the current user is.

Session
-------

Each session has a unique reference called the `session_id` that is very hard to guess. The user holds onto the session_id by way of a cookie which is passed to the server with each request.
The proc [`session_exists`] can be used to test if the session is valid and [auth_session] can be used to return the `user_id` of the session owner.


Host Based Authentication
--------------------------

Host based Authentication or HBA for short associates a user with an IP address. If the remote user is using a particular IP address then we return the `user_id` associated with that unique address. 

HBA is not suitable for hosts behind NAT unless you want to grant the same priviledges to all hosts behind the NAT router.Normally the server only sees the IP address of the NAT router.

The mapping of IP address to user_id is stored in the user table.
The proc [auth_hba_check] can be used to test if the user can be established based on IP address. The proc [auth_hba] can be used to return the `user_id` associated with the IP address of the [current connection][conn_remote_ip] based on the user table.


Password Based Authentication
--------------------------

Password based authentication checks a unique user identifier with a password. The unique identifier could be a username, user code or email address. In this implementation it is a user code.


General
-------

The proc [auth_check] tries to establish if we can authenticate who the current user is by checking session based authentication first and then host based authentication.
 
The proc [auth] returns the `user_id` of the current user by checking session based authentication first and then host based authentication. 

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[session_exists]: procs/session_exists.md

[auth_session]: procs/auth_session.md

[auth_hba]: procs/auth_hba.md
[auth_hba_check]: procs/auth_hba_check.md

[auth_check]: procs/auth_check.md
[auth]: procs/auth.md

[conn_remote_ip]: procs/conn_remote_ip.md

