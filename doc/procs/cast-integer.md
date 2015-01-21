qc::cast integer
================

part of [Casting Procs](../cast.md)

Usage
-----
`qc::cast integer string`

Description
-----------
Try to cast given string into an integer.

Examples
--------
```tcl

% qc::cast integer 2,305
% 2305
% qc::cast integer 2.366%
% 2
% qc::cast integer 43e2
4300

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
