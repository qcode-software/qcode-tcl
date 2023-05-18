proc qc::is::next_url {next_url} {
    #| Absolute next url
    # check that redirection is to the same domain
    set conn_host [qc::conn_host]
    if { ![regexp "^https?://${conn_host}(:\[0-9\]+)?(\\?|#|/|\$)" $next_url] } {
        return 0
    }
    # check for malicious mal-formed url
    if { ![qc::is url $next_url] } {
        return 0 
    }
    
    return 1
}
