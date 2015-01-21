qc::is decimal
==============

part of [Docs](../index.md)

Usage
-----
`qc::is decimal -precision ? -scale ? int`

Description
-----------
Checks if the given string is a decimal number.

If precision and scale are given then checks if the decimal number fits the precision and scale.

If just the precision is given the scale is set to 0.

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
0
% qc::is decimal -precision 5 123
1
% qc::is decimal -precision 4 -scale 1 123.4
1
% qc::is decimal -precision 4 -scale 3 123.4
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"