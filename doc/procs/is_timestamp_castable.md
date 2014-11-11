qc::is_timestamp_castable
=========================

part of [Docs](.)

Usage
-----
`qc::is_timestamp_castable string`

Description
-----------
Can string be cast into timestamp format?

Examples
--------
```tcl

% qc::is_timestamp_castable today
true
% qc::is_timestamp_castable 12/5/12
true
% qc::is_timestamp_castable Mary
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"