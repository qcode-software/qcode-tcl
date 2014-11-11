qc::html_menu
=============

part of [Docs](.)

Usage
-----
`qc::html_menu lmenu`

Description
-----------
Join items to form a horizontal menu

Examples
--------
```tcl

% html_menu [list [html_a Sales sales.html] [html_a Purchasing sales.html] [html_a Accounts sales.html]]
    <a href="sales.html">Sales</a> &nbsp;<b>|</b>&nbsp; <a href="sales.html">Purchasing</a> &nbsp;<b>|</b>&nbsp; <a href="sales.html">Accounts</a>

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"