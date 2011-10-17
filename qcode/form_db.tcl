package provide qcode 1.1
package require doc
namespace eval qc {}
proc qc::form_db { content args } {
    #| Produce HTML to be used with JavaScript behavior dbForm
    if { [llength $args]==1 } {set args [lindex $args 0]}
    array set this $args
    set this(class) clsDbForm
    default this(id) oDbForm
    default this(method) POST
    if { ![info exists this(formType)] } {
	if {[info exists this(submitURL)]} {
	    set this(formType) submit
	} elseif {[info exists this(updateURL)]} {
	    set this(formType) update
	}
    }
    append html [html_tag form [array get this]] \n
    append html "<div class=\"clsDbFormDiv\">\n"
    append html $content \n
    append html "</div>\n"
    append html "<div class=\"clsDbFormDivStatus\">\n"
    append html "</div>\n"
    append html "</form>"

    return $html
}

proc qc::form_db_plain { content args } {
    #| Produce HTML to be used with JavaScript behavior dbForm
    if { [llength $args]==1 } {set args [lindex $args 0]}
    array set this $args
    set this(class) clsDbForm
    default this(id) oDbForm
    return [html form $content [array get this]]
}
