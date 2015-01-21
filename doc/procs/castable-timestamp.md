qc::castable timestamp
=========================

part of [Docs](../index.md)

Usage
-----
`qc::castable timestamp string`

Description
-----------
Test if the given string can be cast to a timestamp without timezone.

Examples
--------
```tcl

% qc::castable timestamp today
true
% qc::castable timestamp 12/5/12
true
% qc::castable timestamp foo
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"