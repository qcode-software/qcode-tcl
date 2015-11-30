qc::cast timestamptz
====================

part of [Cast API](../cast.md)

Usage
-----
`qc::cast timestamptz string`

Description
-----------
Try to convert the given string into an ISO datetime with timezone.

Examples
--------
```tcl

% qc::cast timestamptz today
2015-01-16 10:26:59 +0000
% qc::cast timestamptz 12/5/12
2012-05-12 00:00:00 +0100
% qc::cast timestamptz 12:33:33 
2012-08-12 12:33:33 +0000
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"