qc::cmplen
==========

part of [Docs](../index.md)

Usage
-----
`
        qc::cmplen string1 string2
    `

Description
-----------
Compare length of 2 strings

Examples
--------
```tcl

% qc::cmplen "ox" "hippopotamus"
-1
% qc::cmplen "hippopotamus" "ox"
1
% qc::cmplen "ox" "ox"
0
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"