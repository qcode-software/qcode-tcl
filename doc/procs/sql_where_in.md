qc::sql_where_in
================

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`sql_where_in colName list ?defaultValue?`

Description
-----------
Construct part of a SQL WHERE clause using the IN construct.<br>
    SQL will test column against list of values.
    If list is empty return default value (normally false).

Examples
--------
```tcl

% sql_where_in name {Jimmy Bob Des}
name in (&#39;Jimmy&#39;,&#39;Bob&#39;,&#39;Des&#39;)
%
% sql_where_in t.status_id [list 1 3 5 6]
t.status_id in (1,3,5,6)
%
% sql_where_in col &quot;&quot; true
true

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"