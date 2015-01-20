qc::is decimal
==============

part of [Docs](../index.md)

Usage
-----
`qc::is decimal -precision ? -scale ? int`

Description
-----------
Checks if the given string is a decimal number.

If precision and/or scale are given then checks if the decimal number fits the precision and/or scale.

Examples
--------
```tcl

% qc::is decimal 1234
1
% qc::is decimal foo
0
% qc::is decimal 1.234
1
% qc::is decimal -precision 5 1.2345
1
% qc::is decimal -precision 3 123.45
0
% qc::is decimal -scale 3 123.45
1
% qc::is decimal -scale 1 123.45
0
% qc::is decimal -precision 4 -scale 1 123.4
1
% qc::is decimal -precision 4 -scale 3 123.4
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"