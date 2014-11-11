qc::intplaces
=============

part of [Docs](.)

Usage
-----
`
        qc::intplaces number
    `

Description
-----------
Shift the decimal point n places to the right until $number is an int. Return int and n.

Examples
--------
```tcl

% qc::intplaces 23.4
234 1
% qc::intplaces 0.235
235 3
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"