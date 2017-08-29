qc::sql_list2array
==================

part of [Docs](../index.md)

Usage
-----
`qc::sql_list2array args`

Description
-----------
Convert a list into a PostgrSQL array constructor function call.

Examples
--------
```tcl

% qc::sql_list2array [list "John West" "George East" Harry]
array['John West','George East','Harry']
% qc::sql_list2array [list 1 2 3 4]
array['1','2','3','4']
% qc::sql_list2array -type int [list 1 2 3 4]
array[1::int,2::int,3::int,4::int]::int[]

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"