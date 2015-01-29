Passwords
=======
part of [Qcode Documentation](index.md)

* * *

The qcode-tcl library provides a proc for hashing passwords: [`qc::password_hash`].

The PostgreSQL module [pgcrypto] is used for the hashing so it is required to install the extension in order to make use of password hashing in the qcode-tcl library.



* * *

Qcode Software Limited <http://www.qcode.co.uk>

['qc::password_hash']: procs/password_hash.md
[pgcrypto]: http://www.postgresql.org/docs/9.4/static/pgcrypto.html