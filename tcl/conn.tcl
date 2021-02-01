namespace eval qc {
    namespace export conn_*
}

proc qc::conn_remote_ip {} {
    #| Try to return the remote IP address of the current connection
    #| Trust that a reverse proxy like nginx is setup to pass an X-Forwarded-For header.
    set headers [ns_conn headers]
    if { \
        [ns_set ifind $headers X-Forwarded-For]!=-1 \
        && ( \
               [ns_conn peeraddr] eq "127.0.0.1" \
            || [string match  192.168* [ns_conn peeraddr]] \
            || [ns_conn peeraddr] eq [ns_info address] \
            ) \
        } {
	# Proxied so trust X-Forwarded-For
        # X-Forwarded-For can be a list of IPs. The client IP is always leftmost.
	set forwarded [split [ns_set iget $headers X-Forwarded-For] ,]
        set ip [string trim [lindex $forwarded 0]]
    } else {
	set ip [ns_conn peeraddr]
    }
    return $ip
}

proc qc::conn_url {args} {
    #| Try to construct the full url of this request.
    # Return the encoded version of the path by default unless the -decoded flag is present
    args $args -decoded -- args
    if { [info exist decoded] } {
        return [qc::conn_location][qc::conn_path -decoded]
    } else {
        return [qc::conn_location][qc::conn_path]
    }
}

proc qc::conn_path {args} {
    #| Return the path of the current connection
    #| Return the encoded version of the path by default unless the -decoded flag is present
    # Note: using "ns_conn url" instead of "ns_conn request" as the latter is not updated for "ns_internalredirect"
    args $args -decoded -- args
    if { [info exist decoded] } {
        return [ns_conn url]
    } else {
        # re-ns_urlencode path since Naviserver decodes it by default
        set temp {}
        foreach url_part [split [ns_conn url] /] {
            lappend temp [ns_urlencode -part path $url_part]
        }
        return [join $temp /]
    }
}

proc qc::conn_location { args } {
    #| Try to construct the location
    qc::args $args -conn_protocol ? -conn_host ? -conn_port ? --

    if { ![info exists conn_protocol] } {
        set conn_protocol [ns_conn protocol]
    }
    if { ![info exists conn_host] } {
        set conn_host [ns_set iget [ns_conn headers] Host]
    }
    if { ![info exists conn_port] } {
        set conn_port [ns_set iget [ns_conn headers] Port]
    }

    set url ""
    if { $conn_host ne "" && $conn_port ne "" } {
        # Legacy support - assume if a Port header is present then we're behind a proxy
        # which is emulating Nginx behaviour.
        # eg. Host header with no port and separate Port header.
        switch -exact $conn_port {
            "80" -
            "443" {
                set url "${conn_protocol}://${conn_host}"
            }
            default {
                set url "${conn_protocol}://${conn_host}:${conn_port}"
            }
        }
    } elseif { $conn_host ne "" && $conn_port eq "" } {
        # Return the Host header
        set url "${conn_protocol}://${conn_host}"
    } else {
        set url [ns_conn location]
    }
    if { [qc::is url $url] } {
        return $url
    } else {
        error "conn_location: cannot construct location string"
    }
}

proc qc::conn_port {} {
    #| Try to detect connection port
    if { [regexp {^(https?)://[a-z0-9_][a-z0-9_\-]*(?:\.[a-z0-9_\-]+)+(?::([0-9]+))?} [qc::conn_location] -> protocol port] } {
        if { $port eq "" } {
            return [expr {$protocol eq "http" ? "80" : "443"}]
        } else {
            return $port
        }
    } else {
        error "Can't detect port in url \"[qc::conn_location]\""
    }
}

proc qc::conn_protocol {} {
    #| Try to detect the request protocol
    if { [regexp {^(https?)://} [qc::conn_location] -> protocol] } {
        return $protocol
    } else {
        error "Unknown connection protocol"
    }
}
 
proc qc::conn_host {} {
    #| Return the host indicated in the HTTP/1.1 headers
    return [ns_set iget [ns_conn headers] Host]
}

proc qc::conn_ie {} {
    if { ![ns_conn isconnected] } {
	return false
    }
    set header_set [ns_conn headers]
    set ui_string [ns_set iget $header_set "User-Agent"]
    if { [regexp {[\s;]MSIE\s([1-9][0-9]*)\.[0-9]+[bB]?;} $ui_string] } {
        # MSIE token only specified for IE < 11
    	return true
    } elseif { [regexp {Trident/[1-9][0-9]*\.[0-9]+} $ui_string] } {
        # Trident layout engine for IE >= 9
        return true
    } else {
        return false
    }
}

proc qc::conn_request_is_valid {request} {
    #| Test if the given request string is valid
    set pchar {
        [a-zA-Z0-9\-._~]|%[0-9a-fA-F]{2}|[!$&'()*+,;=:@]
    }
    set query_char [subst -nobackslashes {
        (${pchar}|/|\?)
    }]
    set path_char [subst {
        (${pchar}|/)
    }]
    set abs_uri [subst -nocommands -nobackslashes {
        https?://([a-z0-9\-\.]+)(:[0-9]+)?
        (/${path_char}*)?
        (\?${query_char}+)?
    }]
    set abs_path [subst -nobackslashes {
        /${path_char}*
        (\?${query_char}+)?
    }]
    set method {
        ([A-Z]+)
    }
    set http_version {
        HTTP/([0-9]+\.[0-9]+)
    }
    set re [subst -nocommands -nobackslashes {
        ^
        $method
        \s
        (\*|${abs_uri}|${abs_path})
        \s
        $http_version
        $
    }]
    return [regexp -expanded $re $request]
}

proc qc::conn_if_modified_since {} {
    #| Return the value of the current If-Modified-Since header, if one exists, or "" otherwise.
    # discard Netscape-style additional params
    set headers [ns_conn headers]
    if { [ns_set ifind $headers If-Modified-Since]!=-1 } {
        return [lindex [split [ns_set iget [ns_conn headers] If-Modified-Since] ";"] 0]
    } else {
        return ""
    }
}

proc qc::conn_open {} {
    #| Check if the client connection is open
    set NS_CONN_CLOSED 0x1
    return [expr {
                  [ns_conn isconnected] 
                  && ($NS_CONN_CLOSED & [ns_conn flags]) == 0 
              }]
}

proc qc::conn_response_headers_sent {} {
    #| Inspect ns_conn flags to determine whether response headers have been sent
    set NS_CONN_SENT_HEADERS 0x10
    return [expr {($NS_CONN_SENT_HEADERS & [ns_conn flags]) != 0}]
}

proc qc::conn_served {} {
    #| Return true if a response has been served to the client (connection closed or response headers returned)
    #| Otherwise return false
    return [expr {![qc::conn_open] || [qc::conn_response_headers_sent]}]
    
}

proc qc::conn_method {} {
    #| Return the method of the current connection.
    if {[qc::form_var_exists _method]} {
        set method [qc::form_var_get _method]
    } else {
        set method [ns_conn method]
    }
    return $method
}
