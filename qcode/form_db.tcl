package provide qcode 2.0
package require doc
namespace eval qc {
    namespace export form_db form_db_plain
}

proc qc::form_db { content args } {
    #| Produce HTML to be used with JavaScript behavior dbForm
    array set this $args
    set this(class) "db-form"
    default this(id) oDbForm
    default this(method) POST
    if { ![info exists this(formType)] } {
	if {[info exists this(submitURL)]} {
	    set this(formType) submit
	} elseif {[info exists this(updateURL)]} {
	    set this(formType) update
	}
    }
    append html [html_tag form {*}[array get this]] \n
    append html "<div class=\"db-form-wrapper\">\n"
    append html $content \n
    append html "</div>\n"
    append html "<div class=\"db-form-status\">\n"
    append html "</div>\n"
    append html "</form>"

    return $html
}

proc qc::form_db_plain { content args } {
    #| Produce HTML to be used with JavaScript behavior dbForm
    array set this $args
    set this(class) "db-form"
    default this(id) oDbForm
    return [html form $content {*}[array get this]]
}
