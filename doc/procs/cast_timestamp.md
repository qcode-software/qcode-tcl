qc::cast_timestamp
==================

part of [Casting Procs](../qc/wiki/CastPage)

Usage
-----
`qc::cast_timestamp string`

Description
-----------
Try to convert the given string into an ISO datetime.

Examples
--------
```tcl

% qc::cast_timestamp today
2012-08-16 17:04:47
% qc::cast_timestamp 12/5/12
2012-05-12 00:00:00
% qc::cast_timestamp 12:33:33 
2012-08-12 12:33:33
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"