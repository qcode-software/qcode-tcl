qc::sql_insert_with
===================

part of [Docs](../index.md)

Usage
-----
`qc::sql_insert_with args`

Description
-----------
Construct a SQL INSERT statement using the name value pairs given

Examples
--------
```tcl

% qc::sql_insert_with user_id 1 name "Joe D'Amato" email joe@example.com password munroe
( "user_id","name","email","password" ) values ( 1,'Joe D''Amato','joe@example.com','munroe' )

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"