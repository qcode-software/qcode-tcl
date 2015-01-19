qc::cast smallint
================

part of [Casting Procs](../cast.md)

Usage
-----
`qc::cast smallint string`

Description
-----------
Try to cast the given string into an integer checking if it falls into small int range.
Small int range is -32768 to +32767

Examples
--------
```tcl

% qc::cast smallint 2,305
2305
% qc::cast smallint 2.366%
2
% qc::cast smallint 43e2
4300

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
