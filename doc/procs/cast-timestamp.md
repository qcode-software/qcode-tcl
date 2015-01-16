qc::cast timestamp
==================

part of [Casting Procs](../cast.md)

Usage
-----
`qc::cast timestamp string`

Description
-----------
Try to convert the given string into an ISO datetime.

Examples
--------
```tcl

% qc::cast timestamp today
2012-08-16 17:04:47
% qc::cast timestamp 12/5/12
2012-05-12 00:00:00
% qc::cast timestamp 12:33:33 
2012-08-12 12:33:33
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
