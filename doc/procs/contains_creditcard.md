qc::contains_creditcard
=======================

part of [Docs](.)

Usage
-----
`qc::contains_creditcard string`

Description
-----------
Checks string for occurrences of credit card numbers

Examples
--------
```tcl

% qc::contains_creditcard "This is a string with a CC number 4111111111111111 in it."
true
% qc::contains_creditcard "There's just a phone number here 01311111111 so nothing to see"
false
% qc::contains_creditcard "It won't be fooled by CC-like numbers due to the luhn 10 check 4111111111111112"
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"