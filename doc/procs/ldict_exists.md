qc::ldict_exists
================

part of [Docs](.)

Usage
-----
`
        qc::ldict_exists ldict key
    `

Description
-----------
Return the first index of the dict that contains the the key $key

Examples
--------
```tcl

% set dict_list [list {firstname John surname Mackay} {firstname Andrew surname MacDonald}  {firstname Angus middlename Walter surname McNeil}]
{firstname John surname Mackay} {firstname Andrew surname MacDonald} {firstname Angus middlename Walter surname McNeil}
% qc::ldict_exists $dict_list middlename
2
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"