qc::is_creditcard_masked
========================

part of [Docs](.)

Usage
-----
`qc::is_creditcard_masked no`

Description
-----------
Check the credit card number is masked to PCI requirements

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

[qcode]: www.qcode.co.uk "Qcode Software"