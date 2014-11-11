qc::lshift
==========

part of [Docs](../index.md)

Usage
-----
`
        qc::lshift listVar
    `

Description
-----------
Return leftmost value from list and remove it

Examples
--------
```tcl

% proc call { args } {
set proc_name [qc::lshift args]
return [$proc_name {*}$args]
}
% call qc::base 16 15
F
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"