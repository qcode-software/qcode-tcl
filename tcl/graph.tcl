package provide qcode 2.6.1
package require doc
namespace eval qc {
    namespace export chart_*
}

proc qc::chart_sales {x_labels values tips key_text} {
    set y_max [sigfigs_ceil [max {*}$values] 2]
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

proc qc::chart_list2csv {list} {
    set csv {}
    foreach item $list {
	lappend csv [url_encode [regsub -all {,} $item "#comma#"]]
    }
    return [join $csv ,]
}
