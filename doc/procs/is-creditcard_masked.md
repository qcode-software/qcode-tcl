qc::is creditcard_masked
==============

part of [Docs](../index.md)

Usage
-----
`qc::is creditcard_masked string`

Description
-----------
Checks if the given string is a creditcard number masked to PCI requirements.

Examples
--------
```tcl
% qc::is_creditcard_masked 4111111111111111
0
% qc::is_creditcard_masked 411111****111111
0
% qc::is_creditcard_masked 411111******1111
1
% qc::is_creditcard_masked 411111**********
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"