Passwords
=======
part of [Qcode Documentation](index.md)

* * *

The qcode-tcl library provides a proc for hashing passwords: [`qc::password_hash`].

The PostgreSQL module [pgcrypto] should be installed as [`qc::password_hash`] makes use of the `crypt` function. [`qc::password_hash`] uses the blowfish `bf` algorithm and a default iteration count of 7 however the iteration count may be changed when using [`qc::password_hash`].

More details about the crypt function as well as how to verify passwords can be found in the [Password Hashing Functions] section of pgcrypto documentation.

### Complexity Checking

It's valuable to check if a password meets a certain level of complexity to enhance the security of the password. [`qc::password_complexity_check`] is provided for this purpose.

* * *

Qcode Software Limited <http://www.qcode.co.uk>

[`qc::password_hash`]: procs/password_hash.md
[`qc::password_complexity_check`]: procs/password_complexity_check.md
[pgcrypto]: http://www.postgresql.org/docs/9.4/static/pgcrypto.html
[Password Hashing Functions]: http://www.postgresql.org/docs/9.4/static/pgcrypto.html#AEN157245