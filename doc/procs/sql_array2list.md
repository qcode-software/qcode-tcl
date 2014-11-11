qc::sql_array2list
==================

part of [Docs](.)

Usage
-----
`qc::sql_array2list array`

Description
-----------


Examples
--------
```tcl

% db_1row {select array[&#39;John West&#39;,&#39;George East&#39;,&#39;Harry&#39;] as list}
% set list
{&quot;John West&quot;,&quot;George East&quot;,Harry}
%  qc::sql_array2list {&quot;John West&quot;,&quot;George East&quot;,Harry}
{John West} {George East} Harry

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"