qc::db_eval_column_constraints
===========

part of [Database API](../db.md)

Usage
-----
`db_eval_column_constraints table column values`

Description
-----------
Evaluates constraints on the given table.column with the given values.
Returns a dict of the constraints and their results.

Examples
--------
```tcl

% db_eval_column_constraints test_table col1 [list col1 20 col2 10]
test_table_check t


```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"