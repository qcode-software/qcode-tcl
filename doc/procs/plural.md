qc::plural
==========

part of [Docs](../index.md)

Usage
-----
`
        qc::plural word
    `

Description
-----------
Attempts to return the plural form of a word.
        Assumes the supplied word is not already plural.

Examples
--------
```tcl

% qc::plural dog
dogs
% qc::plural dogs
dogses
% qc::plural formula
formulae
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"