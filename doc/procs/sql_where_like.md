qc::sql_where_like
==================

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`sql_where_like ?varName1 varName2 varName3 ...?`

Description
-----------
Construct part of a SQL WHERE clause using Postgresql's LIKE operator

Examples
--------
```tcl

% set name Jimmy
% set qry "select * from users where [sql_where_like name]"
select * from users where name ~~* '%Jimmy%'
%
% set name "Jimmy Tarbuck"
% set qry "select * from users where [sql_where_like users.name]"
select * from users where users.name ~~* '%Jimmy%' and users.name ~~* '%Tarbuck%'

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"