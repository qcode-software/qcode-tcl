qc::ofc_linechart
=================

part of [Docs](.)

Usage
-----
`
	ofc_linechart ?-id id? ?-title title? ?-x_axis x_axis? ?-y_axis y_axis? ?-width width? ?-height height? lines
    `

Description
-----------
<h2>See Examples in Action</h2>
    [html_a "Examples" "/doc/ofc_line_examples.html"]

Examples
--------
```tcl

set data1 [list \ 
       [list x Jan y 500] \ 
       [list x Feb y 550] \ 
       [list x Mar y 700] \ 
       [list x Apr y 670] \ 
       [list x May y 730]]
set data2 [list  [list x Jan y 50 tooltip "Adwords (Jan)<br>50 Bananas"] \ 
       [list x Feb y 65 tooltip "Adwords (Feb)<br>65 Bananas"] \ 
       [list x Mar y -3 tooltip "Adwords (Mar)<br>-3 Bananas"] \ 
       [list x Apr y 67 tooltip "Adwords (Apr)<br>67 Bananas"] \ 
       [list x May y 73 tooltip "Adwords (May)<br>73 Bananas"]]
set data3 [list  [list x Jan y 500 tooltip "Froogle (Jan)<br>500 Apples"] \ 
       [list x Feb y 605 tooltip "Froogle (Feb)<br>605 Apples"] \ 
       [list x Mar y 700 tooltip "Froogle (Mar)<br>700 Apples"] \ 
       [list x Apr y 607 tooltip "Froogle (Apr)<br>607 Apples"] \ 
       [list x May y 703 tooltip "Froogle (May)<br>703 Apples"]]

Example 1: Minimum Arguments Usage.
set lines [list \ 
       [list label "Direct" data $data1] \ 
       [list label "Adwords" data $data2] \ 
       [list label "Froogle" data $data3]]
qc::return_html [ofc_linechart $lines]

Example 2: Full Arguments Usage.
set id chart2
set title {label "My Wizzy Line Chart" font-size 20px}
set x_axis {label "Months" grid_step 1 label_step 1}
set y_axis {label "Orders" min -100 max 800 step 100} 
set width 50%
set height 25%  
set lines [list \ 
       [list label "Direct" color #00FF33 data $data1] \ 
       [list label "Adwords" color #FF0033 data $data2] \ 
       [list label "Froogle" color #3333CC data $data3]]
qc::return_html [ofc_linechart -id $id -title $title -x_axis $x_axis -y_axis $y_axis -width $width -height $height --  $lines]

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"