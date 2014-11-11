qc::lapply
==========

part of [Docs](.)

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

% proc employee_get { id } {
    set employee_dict [dict create 1 Kagan 2 Boot 3 Bolton 4 Scheunemann 5 Sagan]
    return [dict get $employee_dict $id]
}
% set employee_subset [list 1 3 4]
1 3 4
% qc::lapply employee_get $employee_subset
Kagan Bolton Scheunemann
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"