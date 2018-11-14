qc::db_table_column_types
===========

part of [Database API](../db.md)

Usage
-----
`db_table_column_types table`

Description
-----------
Returns a dict of all columns and their types in the given table.

Examples
--------
```tcl

% db_table_column_types users
user_id int4 firstname plain_string surname plain_string email plain_string

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"