qc::db_column_constraints
===========

part of [Database API](../db.md)

Usage
-----
`db_column_constraints table column`

Description
-----------
Returns a dict of constraint name and check clause for the given column.

Examples
--------
```tcl

% db_column_constraints test_table test_column
test_table_test_column_check {((col1 > 0))}


```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"