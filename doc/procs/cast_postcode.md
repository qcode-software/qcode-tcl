qc::cast_postcode
=================

part of [Casting Procs](../cast.md)

Usage
-----
`qc::cast_postcode postcode`

Description
-----------
Deprecated - see [qc::cast postcode]
Try to cast a string into UK Postcode form

Examples
--------
```tcl

% cast_postcode AB12CD
AB1 2CD
%
% cast_postcode AB123CD
AB12 3CD
%
# Yzero should be YO
% cast_postcode Y023 3CD
YO23 3CD


```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[qc::cast postcode]: cast-postcode.md