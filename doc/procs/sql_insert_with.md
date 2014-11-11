qc::sql_insert_with
===================

part of [Docs](.)

Usage
-----
`qc::sql_insert_with args`

Description
-----------
Construct a SQL INSERT statement using the name value pairs given

Examples
--------
```tcl

% qc::sql_insert_with user_id 1 name &quot;Joe D&#39;Amato&quot; email joe@example.com password munroe
( &quot;user_id&quot;,&quot;name&quot;,&quot;email&quot;,&quot;password&quot; ) values ( 1,&#39;Joe D&#39;&#39;Amato&#39;,&#39;joe@example.com&#39;,&#39;munroe&#39; )

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"