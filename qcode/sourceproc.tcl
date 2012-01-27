package provide qcode 1.3
package require doc
namespace eval qc {}
proc qc::sourceproc {conn ignored} {
    if { [string is true -strict [ns_config ns/server/[ns_info server] testing]] } {
	qc::reload [ns_library private]
	#qc::reload [file join [ns_library private] ../../qc]
    }
    set file [ns_url2file [ns_conn url]]
    if {![file exists $file]} {
        ns_returnnotfound
    } else {
        try {
	    source $file
        } {
	    qc::error_handler
	}
    }
}
