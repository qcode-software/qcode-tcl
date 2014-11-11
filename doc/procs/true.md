qc::true
========

part of [Docs](.)

Usage
-----
`
        qc::true string ?true_return_value? ?false_return_value?
    `

Description
-----------
Test if string is true. Recognised forms are "yes/no" "true/false" or 1/0.
        Optionally set the values to return for each case.

Examples
--------
```tcl

% qc::true 1
true
% qc::true no
false
% qc::true true yes no
yes
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"