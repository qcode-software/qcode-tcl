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
% set qry &quot;select * from users where [sql_where_like name]&quot;
select * from users where name ~~* &#39;%Jimmy%&#39;
%
% set name &quot;Jimmy Tarbuck&quot;
% set qry &quot;select * from users where [sql_where_like users.name]&quot;
select * from users where users.name ~~* &#39;%Jimmy%&#39; and users.name ~~* &#39;%Tarbuck%&#39;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"