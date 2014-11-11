qc::sql_where_cols_start
========================

part of [Database API](../qc/wiki/DatabaseApi)

Usage
-----
`sql_where_cols_start ?varName1 varName2 varName3 ...?`

Description
-----------
Construct a SQL <i>WHERE</i> clause based on local variables.<br>
    Ignore any empty values or non-existent variables.
    Return <code>true</code> if all variables are empty or non-existent.

Examples
--------
```tcl

% set email jim
% sql_where_cols_start email
email ~ &#39;^jim&#39;
% 
% set name J
% set qry &quot;select * from users where [sql_where_cols_start name email]&quot;
select * from users where name ~ &#39;^J&#39; and email ~ &#39;^jim&#39;

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"