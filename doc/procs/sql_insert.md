qc::sql_insert
==============

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`sql_insert varName1 ?varName2 varName3 ...?`

Description
-----------
Construct a SQL INSERT statement using varNames given.

Examples
--------
```tcl

% sql_insert user_id name email password
(user_id,name,email,password) VALUES (:user_id,:name,:email,:password)
%
% set qry "insert into users [sql_insert user_id name email password]"
insert into users (user_id,name,email,password) VALUES (:user_id,:name,:email,:password)
%
% set user_id 3
% set name Bob
% set email bob@monkhouse.com
% set password joke
% 
% db_dml $qry

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"