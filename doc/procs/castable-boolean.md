qc::castable boolean
==============

part of [Docs](../index.md)

Usage
-----
`qc::castable boolean string`

Description
-----------
Test if the given string can be cast to a boolean.

Examples
--------
```tcl

% qc::castable boolean 1
true
% qc::castable boolean 5
false
% qc::castable boolean yes
true
% qc::castable boolean foo
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"