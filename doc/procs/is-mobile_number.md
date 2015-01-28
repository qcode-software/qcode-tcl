qc::is mobile_number
====================

part of [Is API](../is.md)

Usage
-----
`qc::is mobile_number string`

Description
-----------
Checks if the given string is of the form of a UK mobile telephone number.

Examples
--------
```tcl

% qc::is mobile_number " 0 7  986 21299     9"
1
% qc::is mobile_number 09777112112
0
% qc::is mobile_number 013155511111
0
% qc::is mobile_number 07512122122
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"