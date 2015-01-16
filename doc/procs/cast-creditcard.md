qc::cast creditcard
===================

part of [Docs](../index.md)

Usage
-----
`qc::cast creditcard string`

Description
-----------
Cast the given string to a credit card number.

Examples
--------
```tcl

% qc::cast creditcard "4111 1111 1111 1111"
4111111111111111

% qc::cast creditcard "4213 3222 1121 1112"
4213322211211112 is not a valid credit card number

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"