qc::castable decimal
==============

part of [Docs](../index.md)

Usage
-----
`qc::castable decimal ?-precision int? ?-scale int? string`

Description
-----------
Test if the given string can be cast to a decimal with the precision and/or scale if given.

Examples
--------
```tcl

% qc::castable decimal 1.234
true
% qc::castable decimal -precision 4 -scale 3 1.234
true
% qc::castable decimal -scale 2 1.234
true
% qc::castable decimal -precision 4 1.234
true
% qc::castable decimal -precision 2 123.4
false
% qc::castable decimal foo
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"