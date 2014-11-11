qc::in
======

part of [Docs](.)

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

% set banned_hosts [list &quot;polaris&quot; &quot;trident&quot; &quot;poseiden&quot;]
polaris trident poseiden
% qc::in $banned_hosts &quot;arctic&quot;
0
% qc::in $banned_hosts &quot;trident&quot;
1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"