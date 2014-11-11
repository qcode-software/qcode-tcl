qc::db_qry_parse
================

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`db_qry_parse qry ?level?`

Description
-----------
Escape and substitute bind variables in a SQL query. Bind variables are marked with a colon followed by the variable name e.g. :varname The parser will use values of corresponding TCL variables in this namespace or go up the number of levels defined. Values are escaped using db_quote e.g O'Conner becomes O''Conner. Variables that contain an empty string will be treated as NULL (see example below).

Examples
--------
```tcl

% set order_number 123
% db_qry_parse {select order_date from sales_order where order order_number=:order_number}
% select order_date from sales_order where order_number=123

% set name O&#39;Conner
% db_qry_parse {select * from users where name=:name}
% select * from users where name=&#39;O&#39;&#39;Conner&#39;

% set name &quot;&quot;
% db_qry_parse {select * from users where name=:name}
% select * from users where name IS NULL

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"