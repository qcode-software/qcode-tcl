qc::sql_set
===========

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`sql_set ?varName1 varName2 varName3 ...?`

Description
-----------
Take a list of varNames to be used to construct a SQL set statement

Examples
--------
```tcl

% sql_set name email
name=:name, email=:email
%
%
% set user_id 1
% set name Jimmy
% set email jimmy@foo.com
%
% set qry "update users set [sql_set name email] where user_id=:user_id"
update users set name=:name, email=:email where user_id=:user_id
%
# UPDATE THE DATABASE
% db_dml $qry

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"