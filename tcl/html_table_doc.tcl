namespace eval qc {
    namespace export html_table_doc
}

proc qc::html_table_doc {args} {
    #| Create a 2 row table with labels on the first row and values on the 2nd row.
    # Requires a cols object
    set varNames [qc::args2vars $args]
    default tbody {}
    # data is pulled from caller's namespace
    set row {}
    foreach col $cols {
	qc::upcopy 1 [dict get $col name] value
	default value ""
	lappend row $value
    }
    lappend tbody $row
    lappend varNames cols tbody
    return [qc::html_table [dict_from {*}$varNames]]
}

