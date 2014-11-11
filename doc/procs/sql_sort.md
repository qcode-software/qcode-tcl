qc::sql_sort
============

part of [Database API](../db.md)

Usage
-----
`sql_sort colName1 ?colName2 colName3 ...?`

Description
-----------
Create the sql for sorting and paging from form_vars<br/>Default sort order can be specified in args

Examples
--------
```tcl

% sql_sort name email
name,email
%
% sql_sort name DESC,email ASC
name DESC,email
% sql_sort -paging name,email
name,email limit 100 offset 0

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"