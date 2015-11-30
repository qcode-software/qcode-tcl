qc::is_int_castable
===================

part of [Docs](../index.md)

Usage
-----
`qc::is_int_castable string`

Description
-----------
Deprecated - see [qc::castable integer]
Can input be cast to an integer?

Examples
--------
```tcl

% qc::is_int_castable 43e2
true
% qc::is_int_castable  2.366%
true
% qc::is_int_castable 2,305
true
% qc::is_int_castable rolex
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[qc::castable integer]: castable-integer.md