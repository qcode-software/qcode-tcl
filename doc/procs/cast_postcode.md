qc::cast_postcode
=================

part of [Casting Procs](../qc/wiki/CastPage)

Usage
-----
`qc::cast_postcode postcode`

Description
-----------
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

[qcode]: www.qcode.co.uk "Qcode Software"