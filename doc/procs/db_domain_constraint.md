qc::db_domain_constraint
===========

part of [Database API](../db.md)

Usage
-----
`db_domain_constraint domain_name`

Description
-----------
Returns a dict of the constraint name with the check clause for the given domain in the database.

Examples
--------
```tcl

% db_domain_constraint cardinal_number
cardinal_number_domain_check {((VALUE >= 0))}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"