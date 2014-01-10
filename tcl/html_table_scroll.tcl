
package require doc
namespace eval qc {
    namespace export html_table_scroll
}

proc qc::html_table_scroll {args} {
    # varNames can be one of
    # cols tbody tfoot height
    set varNames [qc::args2vars $args]

    default height 600

    set div_style ""
    set div_class [list "scroll"]
    if { [lower $height] eq "max" } {
	lappend div_class "maximize-height"
    } else {
	set div_style [style_set $div_style height ${height}px]
    }
    append html [html_tag div class $div_class style $div_style]
    append html [qc::html_table [dict_from {*}$varNames]]
    append html "</div>\n"

    return $html
}
