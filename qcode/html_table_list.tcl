package provide qcode 1.1
package require doc
namespace eval qc {}

proc qc::html_table_list {args} {
    set varNames [args2vars $args]
    default height 120
    default id dbGridList

    append html [html_tag div class clsScroll style "height:${height}px;border-top:3px solid #ece9d8;border-left:3px solid #ece9d8;border-right:3px solid #ece9d8;"]
    set class clsDbList
    lappend varNames class id
    append html [qc::html_table [dict_from $varNames]]
    append html "</div>\n"
    return $html
}

