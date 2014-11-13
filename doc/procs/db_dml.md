qc::db_dml
==========

part of [Database API](../db.md)

Usage
-----
`db_dml qry`

Description
-----------
Execute a SQL dml statement

Examples
--------
```tcl

% db_dml {update users set email='foo@bar.com' where user_id=23}

% db_dml {insert into users (user_id,name,email) values (1,'john','john@example.com') }

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"