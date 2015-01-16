qc::cast postcode
=================

part of [Casting Procs](../cast.md)

Usage
-----
`qc::cast postcode postcode`

Description
-----------
Try to cast a string into UK Postcode form.

Examples
--------
```tcl

% qc::cast postcode AB12CD
AB1 2CD

% qc::cast postcode AB123CD
AB12 3CD

# Yzero should be YO
% qc::cast postcode Y023 3CD
YO23 3CD


```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"