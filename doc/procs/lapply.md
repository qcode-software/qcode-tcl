qc::lapply
==========

part of [Docs](../index.md)

Usage
-----
`
        qc::lapply func list
    `

Description
-----------
Apply the named procedure to all elements in the list and return a list of the results

Examples
--------
```tcl

% proc user_get { id } {
    set user_dict [dict create 1 Kagan 2 Boot 3 Bolton 4 Scheunemann 5 Sagan]
    return [dict get $user_dict $id]
}
% set user_subset [list 1 3 4]
1 3 4
% qc::lapply user_get $user_subset
Kagan Bolton Scheunemann
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"