qc::list2csv
============

part of [Docs](.)

Usage
-----
`
        qc::list2csv list ?delimiter?
    `

Description
-----------
Convert list to CSV (use of comma as delimiter can be overridden)

Examples
--------
```tcl

% set items [list "jeff" "tom" "dave" "KERRY"]
jeff tom dave KERRY
% qc::list2csv [qc::ltotitle $items]
Jeff,Tom,Dave,Kerry
% qc::list2csv [qc::ltotitle $items] |
Jeff|Tom|Dave|Kerry
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"