qc::sql_where_cols_start
========================

part of [Database API](../db.md)

Usage
-----
`sql_where_cols_start ?varName1 varName2 varName3 ...?`

Description
-----------
Construct a SQL <i>WHERE</i> clause based on local variables.<br>
    Ignore any empty values or non-existent variables.
    Return <code>true</code> if all variables are empty or non-existent.

Examples
--------
```tcl

% set email jim
% sql_where_cols_start email
email ~ '^jim'
% 
% set name J
% set qry "select * from users where [sql_where_cols_start name email]"
select * from users where name ~ '^J' and email ~ '^jim'

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"