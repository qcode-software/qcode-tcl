qc::is_decimal_castable
=======================

part of [Docs](.)

Usage
-----
`qc::is_decimal_castable string`

Description
-----------


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

[qcode]: www.qcode.co.uk "Qcode Software"