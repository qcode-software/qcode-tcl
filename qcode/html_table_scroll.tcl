package provide qcode 1.11
package require doc
namespace eval qc {}
proc qc::html_table_scroll {args} {
    # varNames can be one of
    # cols tbody tfoot height
    set varNames [args2vars $args]

    default height 600

    set div_style ""
    set div_class [list clsScroll]
    if { [lower $height] eq "max" } {
	lappend div_class dynamicResize
    } else {
	set div_style [style_set $div_style height ${height}px]
    }
    append html [html_tag div class $div_class style $div_style]
    append html [qc::html_table [dict_from {*}$varNames]]
    append html "</div>\n"

    return $html
}
