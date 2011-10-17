package provide qcode 1.1
package require doc
namespace eval qc {}

proc qc::html_table_db {args} {
    # cols tbody tfoot height id initialFocus enabled addURL updateURL deleteURL dataURL
    set varNames [args2vars $args]
 
    if { [info exists data] && ![info exists tbody] } {
	set tbody [qc::html_table_tbody_from_ldict $data $cols]
	ldelete varNames [lsearch $varNames data]
	lappend varNames tbody
    }

    if { [info exists table] && ![info exists tbody] } {
	set tbody [lrange $table 1 end]
	ldelete varNames [lsearch $varNames data]
	lappend varNames tbody
    }
    
    # col types
    # encode all text columns by escaping html
    set colIndex 0
    foreach col $cols {
	if { ![dict exists $col type] || [eq [dict get $col type] text] } {
	    dict set col type text
	    for {set rowIndex 0} {$rowIndex < [llength $tbody]} {incr rowIndex} {
		# Try to test if the cell exists but lindex only returns empty string
		if { [ne [set cell [lindex $tbody $rowIndex $colIndex]] ""] } {
		    lset tbody $rowIndex $colIndex [ns_quotehtml $cell]
		}
	    }
	}
	incr colIndex
    }
    set class clsDbGrid
    # rowHeight
    if { [info exists rowHeight] } {
	append html "<style type=\"text/css\">table.$class tr { height:${rowHeight}px;vertical-align:top}</style>"
    }
    default height 500
    default id oDbGrid
    default enabled true
    #
    if { [string is true $enabled] } {
	set headers [ns_conn outputheaders]
	ns_set update $headers Pragma no-cache
	ns_set update $headers Cache-Control no-cache
    }

    append html  "<div class=\"clsDbGridDiv\" style=\"height:$height\">\n"


    lappend varNames class id
    append html [qc::html_table [dict_from [lsort -unique $varNames]]]
    append html "</div>\n"
    append html "<div class=\"clsDbGridDivStatus\" forTable=\"$id\"> <table width=\"100%\"><tr><td></td><td align=\"right\"></td></tr></table> </div>\n"
    return $html
}

proc qc::html_table_db_flexgrid {args} {
    # cols tbody tfoot height id initialFocus enabled addURL updateURL deleteURL dataURL sortable
    set varNames [args2vars $args]
    if { [info exists rowHeight] } {
        append html "<style type=\"text/css\">table.clsDbFlexGrid tr { height:${rowHeight}px;vertical-align:top}</style>"
    }
    default id oDbFlexGrid
    default enabled true
    #
    if { [string is true $enabled] } {
        set headers [ns_conn outputheaders]
        ns_set update $headers Pragma no-cache
        ns_set update $headers Cache-Control no-cache
    }
    append html  "<div class=\"clsDbFlexGridDiv\">\n"

    set class clsDbFlexGrid
    lappend varNames class id
    set dict [dict_from [lsort -unique $varNames]]

    append html [qc::html_table $dict]
    append html "</div>\n"
    return $html
}
