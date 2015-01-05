qc::db_column_table_primary_exists
===========

part of [Database API](../db.md)

Usage
-----
`db_column_table_primary_exists column`

Description
-----------
Checks whether the given column exists as a primary key in the database.

Examples
--------
```tcl

% db_column_table_primary_exists email
false

% db_column_table_primary_exists user_id
true
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"