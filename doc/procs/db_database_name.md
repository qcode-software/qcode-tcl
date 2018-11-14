qc::db_database_name
===========

part of [Database API](../db.md)

Usage
-----
`db_database_name ?poolname?`

Description
-----------
Returns the name of the database for the given pool.

The default poolname is `DEFAULT`.

Examples
--------
```tcl

% db_database_name
test_db

% db_database_name pool2
test_db2

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"