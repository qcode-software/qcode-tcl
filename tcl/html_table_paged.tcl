package provide qcode 2.6.5
package require doc
namespace eval qc {
    namespace export html_table_paged
}

proc qc::html_table_paged { args } {
    #| Split a table up into parts that fit on a printed page.
    # Usage: html_table_paged page_row_count 20 
    # Usage: html_table_paged first_page_row_count 18 page_row_count 20
    # Usage: html_table_paged single_page_row_count 15 first_page_row_count 18 middle_page_row_count 20 last_page_row_count 17
    set args [args2dict $args] 
    dict2vars $args data table tbody cols class page_row_count first_page_row_count middle_page_row_count last_page_row_count single_page_row_count
   
    # tbody from table
    if { [info exists table] && ![info exists tbody] } {
	set tbody [qc::html_table_tbody_from_table $table $cols]
    }
    # tbody from data
    if { [info exists data] && ![info exists tbody] } {
	set tbody [qc::html_table_tbody_from_ldict $data $cols]
        dict unset args data
    }

    # Maximum number of rows to display on a page (excluding thead and tfoot rows)
    if { [info exists page_row_count] } {
        default middle_page_row_count $page_row_count first_page_row_count $page_row_count last_page_row_count $page_row_count
        default single_page_row_count [expr {$first_page_row_count + $last_page_row_count - $middle_page_row_count}]
    }
    
    if { [llength $tbody]<=$single_page_row_count } {
        set tbodies [list $tbody]
    } else {
        # page 1
        lappend tbodies [lrange $tbody 0 [expr $first_page_row_count - 1]]
        for {set index $first_page_row_count} {([llength $tbody]- $index) > $middle_page_row_count} {incr index $middle_page_row_count} {
            # page n
            lappend tbodies [lrange $tbody $index [expr {$index+$middle_page_row_count-1}]]
        }
        # last page
        lappend tbodies [lrange $tbody $index end]
        if {$index < [llength $tbody]-$last_page_row_count} {
            lappend tbodies {}
        }
    }

    # Add class paged
    if { [info exists class] } {
        lappend class paged
    } else {
        set class paged
    }
    dict set args class $class

    set list {}
    foreach tbody $tbodies {
        dict set args tbody $tbody
        lappend list [html_table {*}$args]
    }
    return [join $list \n]
}
