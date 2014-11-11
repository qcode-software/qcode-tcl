qc::false
=========

part of [Docs](.)

Usage
-----
`
        qc::false string ?true_return_value? ?false_return_value?
    `

Description
-----------
Test if string is false. Recognised forms are "yes/no" "true/false" or 1/0.
        Optionally set the values to return for each case.

Examples
--------
```tcl

% qc::false 1
false
% qc::false no
true
% qc::false true yes no
no
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"