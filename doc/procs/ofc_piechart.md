qc::ofc_piechart
================

part of [Docs](.)

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

set data [list {label &quot;Label 1&quot; value 12} {label &quot;Label 2&quot; value 14}]

Example 1: Minumum arguments usage.
qc::return_html [ofc_piechart $data]

Example 2: Full argument usage.   
set id chart2
set title {label &quot;My Wizzzy Pie Chart&quot; font-size 25px}  
set animate true
set width 50%
set height 50%  
qc::return_html [ofc_piechart -id $id -title $title -animate $animate -width $width -height $height -- $data]

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"