qc::is creditcard
==============

part of [Is API](../is.md)

Usage
-----
`qc::is creditcard string`

Description
-----------
Checks if the given string is an allowable credit card number.
Checks number of digits are >13 & <19, all characters are integers, luhn 10 check

Examples
--------
```tcl
% qc::is creditcard 4111111111111111
1
% qc::is creditcard 4111111111111112
0
% qc::is creditcard 41
0
% qc::is creditcard 41111111i1111111
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"