qc::incr0
=========

part of [Docs](.)

Usage
-----
`
        qc::incr0 varName amount
    `

Description
-----------
Increment the value of varName by $amount.

Examples
--------
```tcl

% set total
can't read "total": no such variable
% qc::incr0 total 100
100
% set total
100
% qc::incr0 total 50
150
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"