qc::ldict_exclude
=================

part of [Docs](.)

Usage
-----
`
        qc::ldict_exclude ldict key
    `

Description
-----------
Remove all occurances of $key from the dicts in $ldict

Examples
--------
```tcl

% set dict_list [list {firstname John surname Mackay} {firstname Andrew surname MacDonald}  {firstname Angus middlename Walter surname McNeil}]
{firstname John surname Mackay} {firstname Andrew surname MacDonald} {firstname Angus middlename Walter surname McNeil}
%  qc::ldict_exclude $dict_list firstname
{surname Mackay} {surname MacDonald} {middlename Walter surname McNeil}
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"