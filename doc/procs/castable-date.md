qc::castable date
====================

part of [Castable API](../castable.md)

Usage
-----
`qc::castable date string`

Description
-----------
Test if the given string can be cast to a date.

Examples
--------
```tcl

% qc::castable date 10
true
% qc::castable date "June 22nd"
true
% qc::castable date tomorrow
true
% qc::castable date May
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"