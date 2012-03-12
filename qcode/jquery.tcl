package provide qcode 1.4
package require doc
namespace eval qc {}

proc qc::jquery_toggle_columns {args} {
    #| Returns jQuery html to toggle the display of columns when the corresponding control element is clicked.
    # Usage: jquery_toggle_columns ?-selector_operator selector_operator? table_id control_id1 column_name1 control_id2 column_name2 ...
    # -selector_operator is used to control the jQuery selector matching rule for column name attribute.
    # Example: jquery_toggle_columns -selector_operator ^ sales_report toggle_sales sales.
    # The above example will operate on a table with id sales_report.
    # When the control element with id toggle_sales is clicked then show/hide columns with a name attribute begining with sales. 

    args $args -selector_operator "" -- table_id args
    # args is a list of control_id column_name pairs. 

    # Show/Hide a jQuery set of columns.
    # To improve performance detach table from the DOM, execute jquery on detached table and then reattach table to it's original position on the DOM.
    # This also prevent rogue column borders that sometimes remain after hiding a column. 
    set jquery_script {	
	function show_hide_cols (cols, visibility) {
	    // Dettach table from DOM. 
	    var table = cols.closest("table");
	    var table_parent = table.parent();
	    var table_next_sibling = table.next();
	    table.detach();
	    
	    // show/hide columns
	    if (visibility == "show") {
		cols.css('display','block'); 
	    } else if (visibility == "hide") {
		cols.css('display','none'); 
	    }
	    
	    // Reattach table to it's original position in the DOM.
	    if (table_next_sibling.length) {
		table.insertBefore(table_next_sibling)
	    } else {		    
		table.appendTo(table_parent);
	    }
	    
	    // If table is in a scrollable div update theadFixed.
	    table.closest("div.clsScroll").each(function() {
		jQuery(this).siblings("div.clsNoPrint").remove();
		theadFixed(this);	    
		jQuery(this).siblings("div.clsNoPrint").find("span.clsSort").each(function() {
		    thSortMenu(this);
		});  
	    });	   
	}	
    }
    
    # Attach a toggle event to each control to show/hide corresponding columns.
    foreach {control_id col_name} $args {
	set map [list \$control_id $control_id \$selector_operator $selector_operator \$col_name $col_name \$table_id $table_id]
	append jquery_script [string map $map {
	    jQuery("#$control_id").toggle(
	        function() {
		    var cols = jQuery("col[name$selector_operator=$col_name]", "#$table_id");
		    show_hide_cols(cols, "hide");		
		    return false;
		},
		function() {
		    var cols = jQuery("col[name$selector_operator=$col_name]", "#$table_id");
		    show_hide_cols(cols, "show");
		    return false;
		}
	    );
	}]	
    }

    set html "
	<script type=text/Javascript>
	jQuery(document).ready(function() {
        $jquery_script
	});
    </script>
    "

    return $html
}