package provide qcode 2.6.4
package require doc
namespace eval qc {
    namespace export html_table_db html_table_db_flexgrid
}

proc qc::html_table_db {args} {
    # cols tbody tfoot class height id initialFocus enabled addURL updateURL deleteURL dataURL
    set varNames [qc::args2vars $args]
 
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
		    lset tbody $rowIndex $colIndex [html_escape $cell]
		}
	    }
	}
	incr colIndex
    }
    if { ![info exists class] } {
	set class [list "db-grid" "fixed" "grid" "status-framed"]
    } else {
	if { "db-grid" ni $class } {
	    lappend class "db-grid"
	}
	if { "fixed" ni $class && "flex" ni $class } {
	    lappend class "fixed"
	}
	if { "grid" ni $class } {
	    lappend class "grid"
	}
        if { "status-framed" ni $class } {
            lappend class "status-framed"
        }
    }
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
	ns_set update $headers Expires "Fri, 01 Jan 1990 00:00:00 GMT"
	ns_set update $headers Pragma no-cache
	ns_set update $headers Cache-Control "no-cache, no-store, max-age=0, must-revalidate"
    }

    set scrollHeight $height
    lappend varNames scrollHeight

    lappend varNames class id
    append html [qc::html_table [dict_from {*}[lsort -unique $varNames]]]
    return $html
}

proc qc::html_table_db_flexgrid {args} {
    # cols tbody tfoot class height id initialFocus enabled addURL updateURL deleteURL dataURL sortable
    set varNames [qc::args2vars $args]
    if { [info exists rowHeight] } {
        append html "<style type=\"text/css\">table.db-flex-grid tr { height:${rowHeight}px;vertical-align:top}</style>"
    }
    default id oDbFlexGrid
    default enabled true
    #
    if { [string is true $enabled] } {
        set headers [ns_conn outputheaders]
        ns_set update $headers Pragma no-cache
        ns_set update $headers Cache-Control no-cache
    }
    append html  "<div class=\"db-flex-grid-wrapper\">\n"

    if { ![info exists class] } {
	set class [list "db-grid" flex grid]
    } else {
        if { "db-grid" ni $class } {
            lappend class "db-grid"
        }
        if { "flex" ni $class } {
            lappend class flex
        }
	if { "grid" ni $class } {
	    lappend class grid
	}
    }

    lappend varNames class id
    set dict [dict_from {*}[lsort -unique $varNames]]

    append html [qc::html_table $dict]
    append html "</div>\n"
    return $html
}
