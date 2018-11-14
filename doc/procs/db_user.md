qc::db_user
===========

part of [Database API](../db.md)

Usage
-----
`db_user ?poolname?`

Description
-----------
Returns the name of the user configured to connect to the database for the given pool.

The default poolname is `DEFAULT`.

Examples
--------
```tcl

% db_user
testuser

% db_user pool2
testuser

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"