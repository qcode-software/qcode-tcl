qc::in
======

part of [Docs](../index.md)

Usage
-----
`
        qc::in list item
    `

Description
-----------
Return 1 if $item appears in $list

Examples
--------
```tcl

% set banned_hosts [list "polaris" "trident" "poseiden"]
polaris trident poseiden
% qc::in $banned_hosts "arctic"
0
% qc::in $banned_hosts "trident"
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"