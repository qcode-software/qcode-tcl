qc::castable smallint
==============

part of [Docs](../index.md)

Usage
-----
`qc::castable smallint string`

Description
-----------
Test if the given string can be cast to a smallint.

A small int is an integer in the range of -32768 to +32767

Examples
--------
```tcl

% qc::castable smallint {1,234}
true
% qc::castable smallint foo
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"