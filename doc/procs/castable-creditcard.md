qc::castable creditcard
==============

part of [Castable API](../castable.md)

Usage
-----
`qc::castable creditcard string`

Description
-----------
Test if the given string can be cast to a credit card number.

Examples
--------
```tcl

% qc::castable creditcard "4111 1111 1111 1111"
true
% qc::castable creditcard "4213 3222 1121 1112"
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"