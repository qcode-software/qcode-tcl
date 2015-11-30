qc::is_creditcard
=================

part of [Docs](../index.md)

Usage
-----
`qc::is_creditcard no`

Description
-----------
Deprecated = see [qc::is creditcard]
Checks if no is an allowable credit card number<br/>Checks, number of digits are >13 & <19, all characters are integers, luhn 10 check

Examples
--------
```tcl

% qc::is_creditcard 4111111111111111
1
% qc::is_creditcard 4111111111111112
0
% qc::is_creditcard 41
0
% qc::is_creditcard 41111111i1111111
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"
[qc::is creditcard]: is-creditcard.md