qc::ofc_piechart
================

part of [Docs](../index.md)

Usage
-----
`
	ofc_piechart ?-id id? ?-title title? ?-animate animate? ?-width width? ?-height height? data
    `

Description
-----------
<h2>See Examples in Action</h2>
    [html_a "Examples" "/doc/ofc_pie_examples.html"]

Examples
--------
```tcl

set data [list {label "Label 1" value 12} {label "Label 2" value 14}]

Example 1: Minumum arguments usage.
qc::return_html [ofc_piechart $data]

Example 2: Full argument usage.   
set id chart2
set title {label "My Wizzzy Pie Chart" font-size 25px}  
set animate true
set width 50%
set height 50%  
qc::return_html [ofc_piechart -id $id -title $title -animate $animate -width $width -height $height -- $data]

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"