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
set data2 [list  [list x Jan y 50 tooltip &quot;Adwords (Jan)&lt;br&gt;50 Bananas&quot;] \ 
       [list x Feb y 65 tooltip &quot;Adwords (Feb)&lt;br&gt;65 Bananas&quot;] \ 
       [list x Mar y -3 tooltip &quot;Adwords (Mar)&lt;br&gt;-3 Bananas&quot;] \ 
       [list x Apr y 67 tooltip &quot;Adwords (Apr)&lt;br&gt;67 Bananas&quot;] \ 
       [list x May y 73 tooltip &quot;Adwords (May)&lt;br&gt;73 Bananas&quot;]]
set data3 [list  [list x Jan y 500 tooltip &quot;Froogle (Jan)&lt;br&gt;500 Apples&quot;] \ 
       [list x Feb y 605 tooltip &quot;Froogle (Feb)&lt;br&gt;605 Apples&quot;] \ 
       [list x Mar y 700 tooltip &quot;Froogle (Mar)&lt;br&gt;700 Apples&quot;] \ 
       [list x Apr y 607 tooltip &quot;Froogle (Apr)&lt;br&gt;607 Apples&quot;] \ 
       [list x May y 703 tooltip &quot;Froogle (May)&lt;br&gt;703 Apples&quot;]]

Example 1: Minimum Arguments Usage.
set lines [list \ 
       [list label &quot;Direct&quot; data $data1] \ 
       [list label &quot;Adwords&quot; data $data2] \ 
       [list label &quot;Froogle&quot; data $data3]]
qc::return_html [ofc_linechart $lines]

Example 2: Full Arguments Usage.
set id chart2
set title {label &quot;My Wizzy Line Chart&quot; font-size 20px}
set x_axis {label &quot;Months&quot; grid_step 1 label_step 1}
set y_axis {label &quot;Orders&quot; min -100 max 800 step 100} 
set width 50%
set height 25%  
set lines [list \ 
       [list label &quot;Direct&quot; color #00FF33 data $data1] \ 
       [list label &quot;Adwords&quot; color #FF0033 data $data2] \ 
       [list label &quot;Froogle&quot; color #3333CC data $data3]]
qc::return_html [ofc_linechart -id $id -title $title -x_axis $x_axis -y_axis $y_axis -width $width -height $height --  $lines]

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"