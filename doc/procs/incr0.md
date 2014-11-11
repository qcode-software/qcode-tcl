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
can&#39;t read &quot;total&quot;: no such variable
% qc::incr0 total 100
100
% set total
100
% qc::incr0 total 50
150
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"