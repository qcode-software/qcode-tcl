qc::call
========

part of [Docs](../index.md)

Usage
-----
`
        qc::call proc_name args
    `

Description
-----------
Calls a procedure using local variables as arguments.

Examples
--------
```tcl

% proc employee_record_hash { firstname middlename surname employee_id start_date dept branch } { 
    package require md5
    return [::md5::md5 -hex [list $firstname $middlename $surname $employee_id $start_date $dept $branch]]
}
% qc::call employee_record_hash
Cannot use variable "firstname" to call proc qc::"employee_record_hash":no such variable "firstname"
% set firstname "Angus"
Angus
% set middlename "Jamison"
Jamison
% set surname "Mackay"
Mackay
% set employee_id 999
999
% set start_date "2012-06-01"
2012-06-01
% set dept "Accounts"
Accounts
% set branch "Edinburgh"
Edinburgh
% set employee_hash [qc::call employee_record_hash]
51A01DE13B5C7B5863743A3E5485237D
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"