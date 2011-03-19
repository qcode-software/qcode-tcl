### chart.tcl ###
# DEPRECATED
proc chart_sales {x_labels values tips key_text} {
    set y_max [sigfigs_ceil [max $values] 2]
    set x_labels [chart_list2csv $x_labels]
    set values [chart_list2csv $values]
    set tips [chart_list2csv $tips]
    set html {
	<script type="text/javascript" src="OpenFlashChart/swfobject.js"></script>
	<div id="my_chart" style="width:100%;margin-right:20px;margin-top:10px;margin-bottom:10px;"></div>
 	
	<script type="text/javascript">
	var so = new SWFObject("OpenFlashChart/open-flash-chart.swf", "ofc", "100%", "250", "9", "#FFFFFF");
	so.addVariable("variables","true");
	//so.addVariable("title","Sales,{font-size: 22px;}");
	so.addVariable("bg_colour","#FFFFFF");
	
	so.addVariable("x_labels","$x_labels");
	so.addVariable("x_label_style","11,#474438,0,3"); // font-size,color,orientation (0,1,2), x_label_step
	so.addVariable("x_axis_steps","1"); // draw x grid line every step
	so.addVariable("x_axis_colour","#837d69");
	so.addVariable("x_grid_colour","#c1bfb5");
	
	so.addVariable("y_label_style","11,#474438"); // y_labels font-size,color
	so.addVariable("y_ticks","5,10,4");// length of small tick,length of big tick,number of ticks
	so.addVariable("y_axis_colour","#837d69");
	so.addVariable("y_grid_colour","#c1bfb5");
	so.addVariable("y_min","0");
	so.addVariable("y_max","$y_max");
	so.addVariable("values","$values");
	
	//so.addVariable("area_hollow","4,4,15,#0066FF,Sales,12"); // line_width, dot_size, alpha_shaded, color, key_text,key_font_size
	so.addVariable("line_dot","4,#0066FF,$key_text,14,5"); // line_width,color,key_text,key_text_fontsize,dot_size
	
	so.addVariable("tool_tip","#tip#");
	so.addVariable("tool_tips_set","$tips");
	
	so.addParam("allowScriptAccess", "always" );
	so.write("my_chart");
	</script>
    }
    return [subst -nocommands -nobackslashes $html]
}
# DEPRECATED
proc chart_list2csv {list} {
    set csv {}
    foreach item $list {
	lappend csv [url_encode [regsub -all {,} $item "#comma#"]]
    }
    return [join $csv ,]
}

# New Charts by Daniel Clark 
proc ofc_piechart {args} {

    args $args -id "" -title {} -animate false -width 100% -height 50% -- data
    
    # if id not supplied use global counter to ensure id is unique to allow multiple charts on a html page. 
    if { [eq $id ""] } {
	global ofc_id
	set id graph[incr0 ofc_id 1]
    }

    # convert args into tson and then json for ofc
    #
    # values
    set values {}
    foreach datum $data {
	dict2vars $datum label value tooltip
	set list [list label [list string $label] value $value]
	if { [info exists tooltip] } {
	    lappend list tip [list string $tooltip]
	}
	lappend values [list object {*}$list]
    }	
    set values [list array {*}$values]

    # title
    dict2vars $title label font-size
    if { [info exists label] } {
	set title_style [style_set "" font-family "Arial,Helvetica,sans-serif" text-align center font-size 20px]
	if { [info exists font-size] } {
	    set title_style [style_set $title_style font-size ${font-size}]
	}
	set title [list object text [list string $label] style $title_style]
    }
    
    # default colours
    set no_of_elements [llength $data]
    set colors [list array {*}[ofc_colors $no_of_elements]]

    # construct tson that will be used to generate json loaded by ofc. 
    set tson [list object \
		  elements [list array \
				[list object \
				     type pie \
				     animate $animate \
				     values $values \
				     colours $colors \
				     font-size 14 \
				     tip "#label#:<br>#val# of #total#<br>#percent#" \
				     alpha 1 \
				     starting-angle "35" \
				     gradient-fill true \
				     label-colour 0 \
				     border 2 ]] \
		  title $title \
		  bg_colour #FAFAFA]

    set html [ofc_html $id [tson2json $tson] $width $height]
}

doc ofc_piechart {
    Usage {
	ofc_piechart ?-id id? ?-title title? ?-animate animate? ?-width width? ?-height height? data
    }
    Description {
	<h2>See Examples in Action</h2>
	[html_a "Examples" "/doc/ofc_pie_examples.html"]
    }
    Examples {
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
    }
}

proc /doc/ofc_pie_examples.html {} {
    sset html {
	<script type="text/javascript" src="/JavaScript/swfobject.js"></script> 
	<script type="text/javascript" src="/JavaScript/json2.js"></script> 
    }

    append html [html h2 "Piechart Examples"]

    append html [html h4 {Minimum Argument Usage: "ofc_piechart {$data}"}]
    set data [list {label "Label 1" value 12} {label "Label 2" value 14}]
    append html [ofc_piechart $data]
    
    append html [html h4 {Full Argument Usage: "ofc_piechart -id $id -title $title -animate $animate -width $width -height $height -- $data"}]
    set id chart2
    set title {label "My Wizzzy Pie Chart" font-size 25px}  
    set animate true
    set width 50%
    set height 50%  
    set data [list {label "Label 1" value 12 tooltip "tip 1"} {label "Label 2" value 14 tooltip "tip 2"}]
    append html [ofc_piechart -id $id -title $title -animate $animate -width $width -height $height -- $data]

    qc::return_html $html
}

proc ofc_linechart {args} {

    args $args -id "" -title {} -x_axis {} -y_axis {} -width 100% -height 50% -- lines
    
    if { [eq $id ""] } {
	# if id not supplied use global counter to ensure id is unique to allow multiple charts on a html page. 
	global ofc_id
	set id graph[incr0 ofc_id 1]
    }

    set colors [ofc_colors]

    # find min and max over all lines
    lappend min_values 0
    lappend max_values 0
    set elements {}
    set x_labels {}
    foreach line $lines {
 	dict2vars $line label color data 
	default color [lshift colors]
	
	lassign [ofc_line_element $label $color $data] tson x_labels min max 
	lappend elements $tson
	lappend max_values $max
	lappend min_values $min
    }

    set elements [list array {*}$elements] 
    set x_labels [list array {*}$x_labels]
    set max_value [max $max_values]  
    set min_value [min $min_values]  
    
    # title
    dict2vars $title label font-size
    if { [info exists label] } {
	set title_style [style_set "" font-family "Arial,Helvetica,sans-serif" text-align center font-size 20px]
	if { [info exists font-size] } {
	    set title_style [style_set $title_style font-size ${font-size}]
	}
	set title [list object text [list string $label] style $title_style]
    }

    # x legend
    dict2vars $x_axis label grid_step label_step offset
    default offset false
    default label "" 
    default grid_step 1
    default label_step $grid_step
    set style [style_set "" font-family "Arial,Helvetica,sans-serif" font-size 18px]
    set x_legend [list object style $style text [list string $label]]

    # y legend
    # Default y-axis with 10 steps.
    dict2vars $y_axis label min max step 
    default label "" 
    set style [style_set "" font-family "Arial,Helvetica,sans-serif" font-size 18px]
    set y_legend [list object style $style text [list string $label]]
    default min $min_value
    default max $max_value  
    default step [ofc_step $min $max] 
    set min [expr {ceil(double($min/$step)) * $step}]
    set max [expr {$min + (ceil(double($max-$min)/$step) * $step)}]

    # Construct tson that will be used to generate json loaded by ofc. 
    set tson [list object \
		  elements $elements \
		  x_legend $x_legend \
		  x_axis [list object \
			      steps $grid_step \
			      offset $offset \
			      stroke 1 \
			      colour #000000 \
			      width 6 \
			      grid-colour #dddddd \
			      labels [list object \
					  visible-steps $label_step \
					  size 13 \
					  labels $x_labels]] \
		  y_legend $y_legend \
		  y_axis [list object \
			      min $min \
			      max $max \
			      steps $step \
			      stroke 1 \
			      colour #000000 \
			      grid-colour #dddddd \
			      labels [list object \
					  size 13]] \
		  title $title \
		  bg_colour #FAFAFA]
    
    set html [ofc_html $id [tson2json $tson] $width $height]
}

doc ofc_linechart {
    Usage {
	ofc_linechart ?-id id? ?-title title? ?-x_axis x_axis? ?-y_axis y_axis? ?-width width? ?-height height? lines
    }
    Description {
	<h2>See Examples in Action</h2>
	[html_a "Examples" "/doc/ofc_line_examples.html"]
    }
    Examples {
	set data1 [list \
		       [list x Jan y 500] \
		       [list x Feb y 550] \
		       [list x Mar y 700] \
		       [list x Apr y 670] \
		       [list x May y 730]]
	set data2 [list \
		       [list x Jan y 50 tooltip "Adwords (Jan)<br>50 Bananas"] \
		       [list x Feb y 65 tooltip "Adwords (Feb)<br>65 Bananas"] \
		       [list x Mar y -3 tooltip "Adwords (Mar)<br>-3 Bananas"] \
		       [list x Apr y 67 tooltip "Adwords (Apr)<br>67 Bananas"] \
		       [list x May y 73 tooltip "Adwords (May)<br>73 Bananas"]]
	set data3 [list \
		       [list x Jan y 500 tooltip "Froogle (Jan)<br>500 Apples"] \
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
    }
}

proc /doc/ofc_line_examples.html {} { 

    sset html {
	<script type="text/javascript" src="/JavaScript/swfobject.js"></script> 
	<script type="text/javascript" src="/JavaScript/json2.js"></script> 
    }
    
    set data1 [list \
		   [list x Jan y 500] \
		   [list x Feb y 550] \
		   [list x Mar y 700] \
		   [list x Apr y 670] \
		   [list x May y 730]]
    set data2 [list \
		   [list x Jan y 50 tooltip "Adwords (Jan)<br>50 Bananas"] \
		   [list x Feb y 65 tooltip "Adwords (Feb)<br>65 Bananas"] \
		   [list x Mar y -3 tooltip "Adwords (Mar)<br>-3 Bananas"] \
		   [list x Apr y 67 tooltip "Adwords (Apr)<br>67 Bananas"] \
		   [list x May y 73 tooltip "Adwords (May)<br>73 Bananas"]]
    set data3 [list \
		   [list x Jan y 500 tooltip "Froogle (Jan)<br>500 Apples"] \
		   [list x Feb y 605 tooltip "Froogle (Feb)<br>605 Apples"] \
		   [list x Mar y 700 tooltip "Froogle (Mar)<br>700 Apples"] \
		   [list x Apr y 607 tooltip "Froogle (Apr)<br>607 Apples"] \
		   [list x May y 703 tooltip "Froogle (May)<br>703 Apples"]]

    append html [html h2 "Linechart Examples"]

    append html [html h4 {Minimum Arguments Usage: "ofc_linechart $lines"}]
    set lines [list \
		   [list label "Direct" data $data1] \
		   [list label "Adwords" data $data2] \
		   [list label "Froogle" data $data3]]
    append html [ofc_linechart $lines]

    append html [html h4 {Full Arguments Usage: "ofc_linechart -id $id -title $title -x_axis $x_axis -y_axis $y_axis -width $width -height $height --  $lines"}]
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
    append html [ofc_linechart -id $id -title $title -x_axis $x_axis -y_axis $y_axis -width $width -height $height --  $lines]

    qc::return_html $html
}

proc ofc_line_element {label color data} {
    # return tson for the ofc element
    # each ofc element describes one line

    set x_labels {}
    set y_values {}
    foreach datum $data {
	dict2vars $datum x y tooltip
	default tooltip "$label<br>#val#"
	lappend x_labels [list string $x]
	lappend y_values [list object value $y tip [list string $tooltip]]
	lappend values $y
    }

    set tson [list object \
		  type line \
		  text [list string $label] \
		  colour $color \
		  size 20 \
		  values [list array {*}$y_values]]
    
    return [list $tson $x_labels [min $values] [max $values]]
}

proc ofc_barchart {args} {

    args $args -id "" -title {} -x_axis {} -y_axis {} -width 100% -height 50% -- bars
    
    if { [eq $id ""] } {
	# if id not supplied use global counter to ensure id is unique to allow multiple charts on a html page. 
	global ofc_id
	set id graph[incr0 ofc_id 1]
    }

    set colors [ofc_colors]
    
    # find min and max over all bars
    lappend max_values 0
    lappend min_values 0
    set x_labels {}
    set values {}
    set tson_keys {}
    foreach bar $bars {
 	dict2vars $bar label data 
	lassign [ofc_bar2tson $label $colors $data] tson_values tson_keys pos_total neg_total 

	lappend x_labels [list string $label]
	lappend values $tson_values
	lappend max_values $pos_total
	lappend min_values $neg_total
    }
    set max_value [max $max_values]
    set min_value [min $min_values]
    
    # title
    dict2vars $title label font-size
    if { [info exists label] } {
	set title_style [style_set "" font-family "Arial,Helvetica,sans-serif" text-align center font-size 20px]
	if { [info exists font-size] } {
	    set title_style [style_set $title_style font-size ${font-size}]
	}
	set title [list object text [list string $label] style $title_style]
    }

    # x legend 
    dict2vars $x_axis label grid_step label_step 
    default label "" 
    default grid_step 1
    default label_step $grid_step
    set style [style_set "" font-family "Arial,Helvetica,sans-serif" font-size 18px]
    set x_legend [list object style $style text [list string $label]]

    # y legend
    # Default y-axis with 10 steps.
    dict2vars $y_axis label min max step 
    default label "" 
    set style [style_set "" font-family "Arial,Helvetica,sans-serif" font-size 18px]
    set y_legend [list object style $style text [list string $label]]
    default min $min_value
    default max $max_value  
    default step [ofc_step $min $max] 
    set min [expr {ceil(double($min/$step)) * $step}]
    set max [expr {$min + (ceil(double($max-$min)/$step) * $step)}]

    # Construct tson that will be used to generate json loaded by ofc. 
    set tson [list object \
		  elements [list array \
				[list object \
				     type bar_stack \
				     alpha 0.80 \
				     colours [list array {*}$colors] \
				     values [list array {*}$values] \
				     keys [list array {*}$tson_keys]]] \
		  x_legend $x_legend \
		  x_axis [list object \
			      steps $grid_step \
			      colour #000000 \
			      grid-colour #dddddd \
			      labels [list object \
					  steps $label_step \
					  size 13 \
					  labels [list array {*}$x_labels]]] \
		  y_legend $y_legend \
		  y_axis [list object \
			      min $min \
			      max $max \
			      steps $step \
			      stroke 1 \
			      colour #000000 \
			      grid-colour #dddddd \
			      labels [list object \
					  size 13]] \
		  title $title \
		  tooltip [list object mouse 2] \
		  bg_colour #FAFAFA]
    
    set html [ofc_html $id [tson2json $tson] $width $height]
}

doc ofc_barchart {
    Usage {
	ofc_barchart ?-id id? ?-title title? ?-x_axis x_axis? ?-y_axis y_axis? ?-width width? ?-height height? bars
    }
    Description {
	<h2>See Examples in Action</h2>
	[html_a "Examples" "/doc/ofc_bar_examples.html"]
    }
    Examples {
	set data1 [list \
		       [list x Direct y 500] \
		       [list x Adwords y 750] \
		       [list x Froogle y 70]]
	set data2 [list \
		       [list x Direct y 560 tooltip "Direct (Jan)<br>560 of 1005 Orders"] \
		       [list x Adwords y 395 tooltip "Adwords (Feb)<br>395 of 1005 Orders"] \
		       [list x Froogle y 50 tooltip "Froogle (Mar)<br>50 of 1005 Orders"]]
	set data3 [list \
		       [list x Direct y 600 tooltip "Direct (Jan)<br>600 of 1410 Orders"] \
		       [list x Adwords y 360 tooltip "Adwords (Feb)<br>360 of 1410 Orders"] \
		       [list x Froogle y 450 tooltip "Froogle (Mar)<br>450 of 1410 Orders"]]
	set bars [list \
		      [list label Jan data $data1] \
		      [list label Feb data $data2] \
		      [list label March data $data3]]

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
    }
}

proc /doc/ofc_bar_examples.html {} { 

    sset html {
	<script type="text/javascript" src="/JavaScript/swfobject.js"></script> 
	<script type="text/javascript" src="/JavaScript/json2.js"></script> 
    }
    
    set data1 [list \
		   [list x Direct y 500] \
		   [list x Adwords y 750] \
		   [list x Froogle y 70]]
    set data2 [list \
		   [list x Direct y 560 tooltip "Direct (Jan)<br>560 of 1005 Orders"] \
		   [list x Adwords y 395 tooltip "Adwords (Feb)<br>395 of 1005 Orders"] \
		   [list x Froogle y 50 tooltip "Froogle (Mar)<br>50 of 1005 Orders"]]
    set data3 [list \
		   [list x Direct y 600 tooltip "Direct (Jan)<br>600 of 1410 Orders"] \
		   [list x Adwords y 360 tooltip "Adwords (Feb)<br>360 of 1410 Orders"] \
		   [list x Froogle y 450 tooltip "Froogle (Mar)<br>450 of 1410 Orders"]]
    set bars [list \
		  [list label Jan data $data1] \
		  [list label Feb data $data2] \
		  [list label March data $data3]]

    append html [html h2 "Barchart Examples"]

    append html [html h4 {Minimum Arguments Usage: "ofc_barchart $bars"}]   
    append html [ofc_barchart $bars]

    append html [html h4 {Full Arguments Usage: "ofc_barchart -id $id -title $title -x_axis $x_axis -y_axis $y_axis -width $width -height $height --  $bars"}]
    set id chart2
    set title {label "My Wizzy Bar Chart" font-size 20px}
    set x_axis {label "Months" grid_step 1 label_step 1}
    set y_axis {label "Orders" min 0 max 1500 step 250} 
    set width 50%
    set height 25%     
    append html [ofc_barchart -id $id -title $title -x_axis $x_axis -y_axis $y_axis -width $width -height $height --  $bars]

    qc::return_html $html
}

proc ofc_bar2tson {label colors data} {
    # return tson for the ofc element
    # each ofc values describes one bar
    
    set tson_keys {}
    set y_values {}
    set pos_total 0
    set neg_total 0
    foreach datum $data {
	dict2vars $datum x y tooltip
	default tooltip "$x<br>#val# of #total#"
	lappend tson_keys [list object text [list string $x] colour [lshift colors] font-size 13]
	lappend y_values [list object val $y tip [list string $tooltip]]
	if { $y > 0 } {
	    incr pos_total $y
	} else {
	    incr neg_total $y
	}
    }
    set tson_values [list array {*}$y_values]
    
    return [list $tson_values $tson_keys $pos_total $neg_total]
}

proc ofc_step {min max} {
    # Determine a step value to be used to display a chart with 10 divisions. 
    # Step size should be rounded up to only one sig fig 
    # in order to have nicer increments 
    # eg. for max 960 min 0, step would be 100 instead of 96. 
    if { $min == $max } { 
	return 1 
    } else {
	set step [expr {double(abs($max - $min)) /10}]
	return [sigfigs_ceil $step 1] 
    }
}

proc ofc_colors {{no_of_elements 1}} {
    # 10 preset web safe colours to colour chart elements, if number of elements is odd use 11 instead.
    # #336699/*dark blue*/ #666600/*dark green*/ #CC9933/*dark orange*/ #993366/*dark red*/ 
    # #CCCCCC/*light gray*/ #6699CC/*light blue*/ #999900/*light green*/ #FFCC66/*light orange*/ 
    # #CC9999/*light red*/ #000000/*black*/ #669999/*aqua*/

    set colors [list #336699 #666600 #CC9933 #993366 #CCCCCC #6699CC #999900 #FFCC66 #CC9999 #000000]

    if { [expr $no_of_elements%2] ==  1 } {
	lappend colors #669999
    } 

    return $colors
}

proc ofc_html {id json width height} {   

    # html to construct ofc object.
    sset html {
	<script type="text/javascript"> 
	swfobject.embedSWF("/JavaScript/open-flash-chart.swf?"+Math.floor(Math.random()*10000), "$id", "$width", "$height", "9.0.0", false, {"get-data":"get_data_$id"} );
	
	function get_data_${id}() {
	    return JSON.stringify(data_$id);
	}
	var data_$id =$json
	</script>
    }
    # add div element for ofc to be written into. 
    append html [html div "" id $id]

    return $html
}