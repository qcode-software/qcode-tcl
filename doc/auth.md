Authentication
======================
part of [Qcode Documentation](index.md)

* * *

These procs try to authenticate who the current user is.

Session
-------

Each session has a unique reference called the `session_id` that is very hard to guess. The user holds onto the session_id by way of a cookie which is passed to the server with each request.
The proc [`session_exists`] can be used to test if the session is valid and [`auth_session`] can be used to return the `user_id` of the session owner.

Anonymous User
--------------

The anonymous session is a session that is meant for use by anyone who is not signed in or otherwise assigned their own unique session ID.

The proc [`qc::anonymous_session_id`] can be used to get the current anonymous session ID. If none exists then one will be be created. [`qc::anonymous_session_id`] also keeps the anonymous session fresh by updating the session if it happens to be over an hour old when called.

[`qc::anonymous_user_id`] will return the user ID of anonymous.

### Dependency

The anonymous session is dependent upon a special user being present in the database. Currently the expected `user_id` is `-1` so a user with this user ID should exist before making use of the anonymous session.


Host Based Authentication
--------------------------

Host based Authentication or HBA for short associates a user with an IP address. If the remote user is using a particular IP address then we return the `user_id` associated with that unique address. 

HBA is not suitable for hosts behind NAT unless you want to grant the same priviledges to all hosts behind the NAT router. Normally the server only sees the IP address of the NAT router.

The mapping of IP address to user_id is stored in the user table.
The proc [`auth_hba_check`] can be used to test if the user can be established based on IP address. The proc [`auth_hba`] can be used to return the `user_id` associated with the IP address of the [current connection][conn_remote_ip] based on the user table.


General
-------

The proc [`auth_check`] tries to establish if we can authenticate who the current user is by checking session based authentication first and then host based authentication.
 
The proc [`auth`] returns the `user_id` of the current user by checking session based authentication first and then host based authentication. 

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[`session_exists`]: procs/session_exists.md

[`auth_session`]: procs/auth_session.md

[`auth_hba`]: procs/auth_hba.md
[`auth_hba_check`]: procs/auth_hba_check.md

[`auth_check`]: procs/auth_check.md
[`auth`]: procs/auth.md

[conn_remote_ip]: procs/conn_remote_ip.md

[`qc::anonymous_session_id`]: procs/anonymous_session_id.md
[`qc::anonymous_user_id`]: procs/anonymous_user_id.md

