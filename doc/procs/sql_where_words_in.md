qc::sql_where_words_in
======================

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`sql_where_words_in name phrase`

Description
-----------
Construct part of a SQL WHERE clause to find a word in a string

Examples
--------
```tcl

% set name "Jimmy Carr"
% set qry "select * from users where [sql_where_words_in name $name]"
select * from users where name ~ '( |^)Jimmy( |$)' and name ~ '( |^)Carr( |$)'

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"