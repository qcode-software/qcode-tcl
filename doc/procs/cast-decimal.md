qc::cast decimal
================

part of [Cast API](../cast.md)

Usage
-----
`qc::cast decimal ?-precision int? ?-scale int? string`

Description
-----------
Try to cast given string into a decimal value.
If precision and/or scale are provided then try to cast the value to the precision and scale.

Examples
--------
```tcl

% qc::cast decimal 2,305.25
2305.25
% qc::cast decimal 2.366%
2.366
% qc::cast decimal -scale 2 3.689
3.69
% qc::cast decimal -precision 4 3.6899 
3.690
% qc::cast decimal -precision 4 -scale 2 32.4556
32.46
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"