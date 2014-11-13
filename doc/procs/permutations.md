qc::permutations
================

part of [Docs](../index.md)

Usage
-----
`
        qc::permutations list 
    `

Description
-----------
Returns all permuations of the supplied list

Examples
--------
```tcl

% qc::permutations [list a b c]
{c b a} {c a b} {b c a} {a c b} {b a c} {a b c}
% qc::permutations [list a]
a
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"