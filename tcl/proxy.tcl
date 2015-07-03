namespace eval qc {
    namespace export proxy_upstream
}

proc qc::proxy_upstream { args } {
    #| Proxy a request to an upstream server
    qc::args $args -log_headers -timeout 60:0 -spoolsize 10000 -- target

    #
    # Assemble URL
    #
    set url $target
    set path [ns_conn url]
    append url $path
    set query [ns_conn query]
    if {$query ne ""} {append url ?$query}
    set port [ns_conn port]
    set content [ns_conn content]
    set http_cmd [expr {[string match https://* $target] ? "ns_ssl" : "ns_http"}]
    # Set default ports if not present in URL
    if { $port == 0 && $http_cmd eq "ns_ssl" } {
        set port 443
    } elseif { $port == 0 } {
        set port 80
    }

    #
    # Update Headers
    #
    set query_headers [ns_conn headers]
    ns_set update $query_headers X-Forwarded-For [ns_conn peeraddr]
    ns_set update $query_headers X-Forwarded-Host [ns_set iget $query_headers Host]
    ns_set update $query_headers Port $port
    #ns_set delkey $query_headers Host

    #
    # Build query for the upstream server
    # This requires a Naviserver build later than 4.99.8-1 to allow
    # keep_host_header
    #
    set cmd $http_cmd
    lappend cmd queue \
        -method [ns_conn method] \
        -headers $query_headers \
        -keep_host_header \
        -timeout $timeout
    if {$content ne ""} {lappend cmd -body $content}
    lappend cmd $url
    if { [info exists log_headers] } {
        qc::log Notice ">>> start of request headers to upstream >>>"
        foreach {name value} [ns_set array $query_headers] {
            qc::log Notice "$name: $value"
        }
        qc::log Notice ">>> end of request headers to upstream >>>"
    }

    set handle [{*}$cmd]

    #
    # Build reply headers
    #
    set reply_headers [ns_set create]
    ns_set update $reply_headers X-Processed Naviserver

    #
    # Wait for results
    #
    $http_cmd wait -timeout $timeout -result result -headers $reply_headers -status status -spoolsize $spoolsize -file spooled_response $handle

    if { [info exists log_headers] } {
        qc::log Notice "<<< start of reply headers from upstream <<<"
        foreach {name value} [ns_set array $reply_headers] {
            qc::log Notice "$name: $value"
        }
        qc::log Notice "<<< end of reply headers from upstream <<<"
    }
    set content_type [ns_set iget $reply_headers content-type]
    # Don't pass back connection, date or server headers if present
    foreach header [list "connection" "date" "server"] {
        if { [set index [ns_set ifind $reply_headers $header]] > -1 } {
            ns_set delete $reply_headers $index
            unset index
        }
    }

    if {[info exists spooled_response]} {
        qc::log "Spooled [file size $spooled_response] bytes to $spooled_response"
        ns_respond -status $status -type $content_type -headers $reply_headers -file $spooled_response
        file delete $spooled_response
    } else {
        qc::log "Response received directly"
        ns_respond -status $status -type $content_type -headers $reply_headers -binary $result
    }
}
