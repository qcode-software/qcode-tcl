qc::db_eval_constraint
===========

part of [Database API](../db.md)

Usage
-----
`db_eval_constraint table constraint args`

Description
-----------
Check a database constraint expression by substituting in corresponding values from args.

Examples
--------
```tcl

% db_eval_constraint test_table {(col1 > col2)} col1 10 col2 20
f

% db_eval_constraint test_table {(col1 > col2)} col1 20 col2 10
t

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"