qc::castable postcode
====================

part of [Docs](../index.md)

Usage
-----
`qc::castable postcode string`

Description
-----------
Test if the given string can be cast to a UK postcode.

Examples
--------
```tcl

% qc::castable postcode AB12CD
true
% qc::castable postcode AB123CD
true

# Yzero should be YO
% qc::castable postcode Y023 3CD
true

% qc::castable postcode 123
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"