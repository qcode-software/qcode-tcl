qc::sql_where_like
==================

part of [Database API](../db.md)

Usage
-----
`sql_where_like ?name1 value1 name2 value2 ...?`

Description
-----------
Construct part of a SQL WHERE clause using Postgresql's LIKE operator

Examples
--------
```tcl

% set name Jimmy
% set qry "select * from users where [sql_where_like name $name]"
select * from users where name ~~* '%Jimmy%'
%
% set name "Jimmy Tarbuck"
% set qry "select * from users where [sql_where_like users.name $name]"
select * from users where users.name ~~* '%Jimmy%' and users.name ~~* '%Tarbuck%'

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
