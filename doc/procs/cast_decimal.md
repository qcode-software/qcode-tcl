qc::cast_decimal
================

part of [Casting Procs](../cast.md)

Usage
-----
`qc::cast_decimal string ?precision?`

Description
-----------
Deperecated - see [qc::cast decimal]
Try to cast given string into a decimal value

Examples
--------
```tcl

% cast_decimal 2,305.25
% 2305.25
% 
% cast_decimal 2.366%
% 2.366
%
% cast_decimal 3.689 2
3.69

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[qc::cast decimal]: cast-decimal.md