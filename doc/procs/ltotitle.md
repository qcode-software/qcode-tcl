qc::ltotitle
============

part of [Docs](../index.md)

Usage
-----
`
        qc::ltotitle list
    `

Description
-----------
Make each word totitle excepting some industry specific acronyms

Examples
--------
```tcl

% set items [list jeff tom dave KERRY CCTV]
jeff tom dave KERRY CCTV
% qc::ltotitle $items
Jeff Tom Dave Kerry CCTV
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"