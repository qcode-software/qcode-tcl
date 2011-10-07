package provide qcode 1.0
package require doc
namespace eval qc {}
proc qc::html_table_scroll {args} {
    # varNames can be one of
    # cols tbody tfoot height
    set varNames [args2vars $args]

    default height 600

    append html [html_tag div class clsScroll style "height:${height}px"]
    append html [qc::html_table [dict_from $varNames]]
    append html "</div>\n"

    return $html
}
