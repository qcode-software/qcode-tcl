namespace eval qc {
    namespace export handler_restful handler_files handler_db_files
}

proc qc::handler_restful {} {
    #| Handler for registered restful URL handlers.
    set url_path [qc::conn_path]
    set method [qc::conn_method]
    
    if {[qc::handlers exists $method $url_path]} {
        set result [qc::handlers call $method $url_path]
        # Check if conn is still waiting to be served
        if { ![qc::conn_served] } {
            # If a non-GET method then return the global data structure otherwise return the result as text/html.
            if {$method ne "GET"} {
                return [qc::return_response]
            } else {
                return [ns_return 200 text/html $result]
            }
        }
    }
}

proc qc::handler_files {} {
    #| Handler for file requests that haven't been resolved by fastpath.
    set url_path [qc::conn_path]
    if { [file exists [ns_pagepath]$url_path] } {
        # static file
        ns_register_fastpath GET $url_path
        ns_register_fastpath HEAD $url_path
        ns_returnfile 200 [ns_guesstype [ns_pagepath]$url_path] [ns_pagepath]$url_path
    }
}

proc qc::handler_db_files {} {
    #| Handle requests for files stored in the database that have yet to be cached on disk
    set url_path [qc::conn_path]
    if { [regexp {^/image/} $url_path] } {
        # images
        qc::image_handler [ns_pagepath]/image
    } elseif { [regexp {^/file/} $url_path] } {
        qc::file_handler [ns_pagepath]/file
    }
}