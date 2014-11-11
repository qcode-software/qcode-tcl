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

% qc::contains_creditcard &quot;This is a string with a CC number 4111111111111111 in it.&quot;
true
% qc::contains_creditcard &quot;There&#39;s just a phone number here 01311111111 so nothing to see&quot;
false
% qc::contains_creditcard &quot;It won&#39;t be fooled by CC-like numbers due to the luhn 10 check 4111111111111112&quot;
false
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"