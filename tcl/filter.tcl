namespace eval qc {
    namespace export filter_fastpath_gzip filter_set_expires
}

proc qc::filter_fastpath_gzip {filter_when file_extensions} {
    #| Postauth filter to seed filesystem with .gz versions of static files if the client accepts gzip-ed content.
    set conn_path [qc::conn_path]
    set file_path [ns_pagepath]$conn_path
    set gzipped_file_path [ns_pagepath]${conn_path}.gz
    
    if { [ns_conn zipaccepted] && ![file readable $gzipped_file_path] && [file readable $file_path] && [file extension $file_path] in $file_extensions && [file type $file_path] in [list "link" "file"] } {
        ns_gzipfile $file_path $gzipped_file_path
    }
    return "filter_ok"
}

proc qc::filter_set_expires {filter_when seconds {cache_response_directive ""}} {
    #| Postauth filter to set cache control headers: Expires, & Cache-Control. 
    #| If "cache_response_directive" is specified the function adds the "max-age" header field to the response "Cache-Control" header.
    # cache_response_directive: public, private, no-cache, no-store, no-transform, must-revalidate, or proxy-revalidate
    if { $cache_response_directive ne "" } {
        ns_setexpires -cache-control $cache_response_directive $seconds
    } else {
        ns_setexpires $seconds
    }
    return "filter_ok"
}