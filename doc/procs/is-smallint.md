qc::is smallint
==============

part of [Docs](../index.md)

Usage
-----
`qc::is smallint int`

Description
-----------
Checks if the given string is a small integer.
A small integer is an integer in the range of -32768 to +32767.

Examples
--------
```tcl

% qc::is smallint 123
1
% qc::is smallint -35000
0
% qc::is smallint 1,234
1
% qc::is smallint foo
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"