qc::is_decimal_castable
=======================

part of [Docs](../index.md)

Usage
-----
`qc::is_decimal_castable string`

Description
-----------
Deprecated - see [qc::castable decimal]

Examples
--------
```tcl

% qc::is_decimal_castable 2,305.25
true
% qc::is_decimal_castable 2.366%
true
% qc::is_decimal_castable 1A
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[qc::castable decimal]: castable-decimal.md