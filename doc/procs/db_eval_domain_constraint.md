qc::db_eval_domain_constraint
===========

part of [Database API](../db.md)

Usage
-----
`db_eval_domain_constraint domain_name value`

Description
-----------
Evaluates the domain constraint against the given value.

See the [PostgreSQL documentation](http://www.postgresql.org/docs/9.3/static/sql-createdomain.html) for information about domains.

Examples
--------
```tcl

% db_eval_domain_constraint cardinal_number -10
f

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"