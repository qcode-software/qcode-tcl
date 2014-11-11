qc::sql_where_in_not
====================

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`sql_where_in_not colName list ?defaultValue?`

Description
-----------
Negation of <proc>sql_where_in</proc>
    Construct part of a SQL WHERE clause using the IN construct.<br>
    SQL will test where column is not in the list of values.
    If list is empty return default value (normally true).

Examples
--------
```tcl

% sql_where_in_not name {Jimmy Bob Des}
name not in ('Jimmy','Bob','Des')
%
% sql_where_in_not t.status_id [list 1 3 5 6]
t.status_id not in (1,3,5,6)
%
% sql_where_in_not col ""
true

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"