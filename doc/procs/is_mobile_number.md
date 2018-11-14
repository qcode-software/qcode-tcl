qc::is_mobile_number
====================

part of [Docs](../index.md)

Usage
-----
`qc::is_mobile_number string`

Description
-----------
Deprecated - see [qc::is mobile_number]

Examples
--------
```tcl

% qc::is_mobile_number " 0 7  986 21299     9"
true
% qc::is_mobile_number 09777112112
false
% qc::is_mobile_number 013155511111
false
% qc::is_mobile_number 07512122122
true
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[qc::is mobile_number]: is-mobile_number.md