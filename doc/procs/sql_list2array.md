qc::sql_list2array
==================

part of [Docs](.)

Usage
-----
`qc::sql_list2array args`

Description
-----------
Convert a list into a PostgrSQL array literal.

Examples
--------
```tcl

% qc::sql_list2array [list &quot;John West&quot; &quot;George East&quot; Harry]
array[&#39;John West&#39;,&#39;George East&#39;,&#39;Harry&#39;]
% qc::sql_list2array [list 1 2 3 4]
array[&#39;1&#39;,&#39;2&#39;,&#39;3&#39;,&#39;4&#39;]
% qc::sql_list2array -type int [list 1 2 3 4]
array[1::int,2::int,3::int,4::int]::int[]

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"