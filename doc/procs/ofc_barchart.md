qc::ofc_barchart
================

part of [Docs](.)

Usage
-----
`
	ofc_barchart ?-id id? ?-title title? ?-x_axis x_axis? ?-y_axis y_axis? ?-width width? ?-height height? bars
    `

Description
-----------
<h2>See Examples in Action</h2>
    [html_a "Examples" "/doc/ofc_bar_examples.html"]

Examples
--------
```tcl

set data1 [list \ 
       [list label Direct y 500] \ 
       [list label Adwords y 750] \ 
       [list label Froogle y 70]]
set data2 [list \ 
       [list label Direct y 560 tooltip "Direct (Jan)<br>560 of 1005 Orders"] \ 
       [list label Adwords y 395 tooltip "Adwords (Feb)<br>395 of 1005 Orders"] \ 
       [list label Froogle y 50 tooltip "Froogle (Mar)<br>50 of 1005 Orders"]]
set data3 [list \ 
       [list label Direct y 600 tooltip "Direct (Jan)<br>600 of 1410 Orders"] \ 
       [list label Adwords y 360 tooltip "Adwords (Feb)<br>360 of 1410 Orders"] \ 
       [list label Froogle y 450 tooltip "Froogle (Mar)<br>450 of 1410 Orders"]]
set bars [list \ 
      [list x Jan data $data1] \ 
      [list x Feb data $data2] \ 
      [list x March data $data3]]

Example 1: Minimum Arguments Usage.
qc::return_html [ofc_barchart $bars]

Example 2: Full Arguments Usage.
set id chart2
set title {label "My Wizzy Bar Chart" font-size 20px}
set x_axis {label "Months" grid_step 1 label_step 1}
set y_axis {label "Orders" min 0 max 1500 step 250} 
set width 50%
set height 25%  
qc::return_html [ofc_barchart -id $id -title $title -x_axis $x_axis -y_axis $y_axis -width $width -height $height --  $bars]

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"