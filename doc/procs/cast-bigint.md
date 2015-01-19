qc::cast bigint
================

part of [Casting Procs](../cast.md)

Usage
-----
`qc::cast bigint string`

Description
-----------
Try to cast the given string into an integer checking if it falls into big int range.
Big int range is -9223372036854775808 to +9223372036854775807

Examples
--------
```tcl

% qc::cast bigint 2,305
2305
% qc::cast bigint 2.366%
2
% qc::cast bigint 43e2
4300

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
