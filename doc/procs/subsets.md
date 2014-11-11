qc::subsets
===========

part of [Docs](.)

Usage
-----
`
        qc::subsets list length
    `

Description
-----------
Returns all possible subsets of length n from list l.

Examples
--------
```tcl

% qc::subsets [list a b c d e f g h i] 9
{a b c d e f g h i}
% qc::subsets [list a b c d e f g h i] 8
{a b c d e f g h} {a b c d e f g i} {a b c d e f h i} {a b c d e g h i} {a b c d f g h i} {a b c e f g h i} {a b d e f g h i} {a c d e f g h i} {b c d e f g h i}
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"