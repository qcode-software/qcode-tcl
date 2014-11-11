qc::call
========

part of [Docs](.)

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
Cannot use variable &quot;firstname&quot; to call proc qc::&quot;employee_record_hash&quot;:no such variable &quot;firstname&quot;
% set firstname &quot;Angus&quot;
Angus
% set middlename &quot;Jamison&quot;
Jamison
% set surname &quot;Mackay&quot;
Mackay
% set employee_id 999
999
% set start_date &quot;2012-06-01&quot;
2012-06-01
% set dept &quot;Accounts&quot;
Accounts
% set branch &quot;Edinburgh&quot;
Edinburgh
% set employee_hash [qc::call employee_record_hash]
51A01DE13B5C7B5863743A3E5485237D
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"