qc::sql_where_col_starts
========================

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`sql_where_col_starts colName value1 ?value2 value3...?`

Description
-----------
Construct a SQL <i>WHERE</i> clause matching the start of the column value.

Examples
--------
```tcl

% sql_where_col_starts email jim
email ~ '^jim'
% 
% sql_where_col_starts name Jim Mac
name ~ '^Jim' or name ~ '^Mac'

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"