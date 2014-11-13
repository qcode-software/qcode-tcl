qc::lexclude
============

part of [Docs](../index.md)

Usage
-----
`
        qc::lexclude list value ?value? ?value? ...
    `

Description
-----------
Return $list with and values listed in $args excluded

Examples
--------
```tcl

% set items [list Angus Jamison Jock Mackay]     
Angus Jamison Jock Mackay
% qc::lexclude $items "Jock" "Mackay"
Angus Jamison
% set items [list 1 2 2 2 3 4 4 4 4]
1 2 2 2 3 4 4 4 4
% qc::lexclude $items 2
1 3 4 4 4 4
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"