package provide qcode 1.7
package require doc
namespace eval qc {}

proc qc::html_table_doc {args} {
    set varNames [args2vars $args]
    default tbody {}
    # data is pulled from caller's namespace
    set row {}
    foreach col $cols {
	upcopy 1 [dict get $col name] value
	default value ""
	lappend row $value
    }
    lappend tbody $row
    lappend varNames cols tbody
    return [qc::html_table [dict_from {*}$varNames]]
}


