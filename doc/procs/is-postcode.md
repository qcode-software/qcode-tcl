qc::is postcode
===============

part of [Docs](../index.md)

Usage
-----
`qc::is postcode postcode`

Description
-----------
Checks if the given string is a UK postcode.

Examples
--------
```tcl

% qc::is postcode EH3
0
% qc::is postcode "BFPO 61"
1
% qc::is postcode "EH3 9EE"
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[qc::is postcode]: is-postcode.md