qc::db_dml
==========

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`db_dml qry`

Description
-----------
Execute a SQL dml statement

Examples
--------
```tcl

% db_dml {update users set email=&#39;foo@bar.com&#39; where user_id=23}

% db_dml {insert into users (user_id,name,email) values (1,&#39;john&#39;,&#39;john@example.com&#39;) }

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"