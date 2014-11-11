qc::sql_in
==========

part of [Docs](.)

Usage
-----
`qc::sql_in list ?type?`

Description
-----------
Return a SQL comma separated list

Examples
--------
```tcl

% qc::sql_in [list blue yellow orange]
(&#39;blue&#39;,&#39;yellow&#39;,&#39;orange&#39;)

% set qry &quot;select * from users where surname in [qc::sql_in [list Campbell Graham Fraser]]&quot;
select * from users where surname in (&#39;Campbell&#39;,&#39;Graham&#39;,&#39;Fraser&#39;)

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"