qc::ldict_set
=============

part of [Docs](.)

Usage
-----
`
        qc::ldict_set ldictVar index key value
    `

Description
-----------
Takes a list of dicts and sets the value for $key in the dict at $index.

Examples
--------
```tcl

% set dict_list [list {firstname John surname Mackay} {firstname Angus surname McNeil}]
{firstname John surname Mackay} {firstname Angus surname McNeil}
% qc::ldict_set dict_list 1 surname Jamison
{firstname John surname Mackay} {firstname Angus surname Jamison}
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"