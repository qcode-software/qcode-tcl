qc::ll_sum
==========

part of [Docs](.)

Usage
-----
`
        qc::ll_sum llVar index
    `

Description
-----------
Traverses a list of lists and returns the sum of values at $index in each list

Examples
--------
```tcl

1&gt; set llist [list {widget_a 9.99 19} {widget_b 8.99 19} {widget_c 7.99 1}]
{widget_a 9.99 19} {widget_b 8.99 19} {widget_c 7.99 1}
2&gt; qc::ll_sum llist 2
39
```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"