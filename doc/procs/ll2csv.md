qc::ll2csv
==========

part of [Docs](.)

Usage
-----
`
        qc::ll2csv llist ?separator?
    `

Description
-----------
Convert a list of lists into a csv.
        Defaults to comma separated but allows the passing of alternative delimiters.

Examples
--------
```tcl

% set llist [list {widget_a 9.99 19} {widget_b 8.99 19} {widget_c 7.99 1}]
{widget_a 9.99 19} {widget_b 8.99 19} {widget_c 7.99 1}

% qc::ll2csv $llist
widget_a,9.99,19
widget_b,8.99,19
widget_c,7.99,1

% qc::ll2csv $llist |
widget_a|9.99|19
widget_b|8.99|19
widget_c|7.99|1
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"