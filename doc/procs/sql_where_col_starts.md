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
email ~ &#39;^jim&#39;
% 
% sql_where_col_starts name Jim Mac
name ~ &#39;^Jim&#39; or name ~ &#39;^Mac&#39;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"