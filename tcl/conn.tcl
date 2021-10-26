namespace eval qc {
    namespace export conn_*
}

proc qc::conn_remote_ip {} {
    #| Try to return the remote IP address of the current connection

    # Get direct peer IP
    set ip [ns_conn peeraddr]

    # Check for X-Forwarded-For header
    set headers [ns_conn headers]
    if { [ns_set ifind $headers X-Forwarded-For]!=-1 } {
	# Proxied so use X-Forwarded-For

        # X-Forwarded-For can be a list of IPs. Guess the client IP is leftmost.
	set forwarded [split [ns_set iget $headers X-Forwarded-For] ,]
        set ip_forwarded [string trim [lindex $forwarded 0]]

        # Validate X-Forwarded-For value
        if { [qc::is ipv4 $ip_forwarded] } {
            # Valid ipv4 so clobber peeraddr
            set ip $ip_forwarded
        }
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
        set conn_protocol [qc::conn_protocol]
    }
    if { ![info exists conn_host]} {
        set conn_host [qc::conn_host]
    }
    if { ![info exists conn_port] } {
        set conn_port [qc::conn_port]
    }

    set url "${conn_protocol}://${conn_host}"
    # Legacy support where port doesn't appear in host header
    if { $conn_port ne "" && $conn_port != 80 && $conn_port != 443 } {
        # if Host header doesn't contain port, append it.
        if { [string first ":" $conn_host] == -1 } {
            set url "${conn_protocol}://${conn_host}:${conn_port}"
        }
    }

    if { [qc::is url $url] } {
        return $url
    } else {
        error "conn_location: cannot construct location string"
    }
}

proc qc::conn_protocol { } {
    #| Return protocol used by the client
    set conn_headers [ns_conn headers]
    
    # The connection protocol here may be different to the one initiated
    # by the client. Check X-Forward-Proto for initiating protocol.
    set client_protocol [ns_set iget $conn_headers "x-forwarded-proto"]
    if { $client_protocol in [list "https" "http"] } {
        return $client_protocol
    } else {
        return [ns_conn protocol]
    }
}

proc qc::conn_port { } {
    #| Try to detect connection port
    set conn_headers [ns_conn headers]
   
    # The connection port here may be different to the one initiated
    # by the client. Check X-Forward-Port for initiating port.
    set client_port [ns_set iget $conn_headers "x-forwarded-port"]
    if { $client_port ne "" && [qc::is int $client_port] } {
        return $client_port
    } elseif { [set port_header [ns_set iget $conn_headers "port"]] ne "" } {
        # Legacy support where Port is never included in host header and has its
        # own header value.
        return $port_header
    } else {
        # Otherwise take it from the Host header
        if { [regexp {[a-z0-9_][a-z0-9_\-]*(?:\.[a-z0-9_\-]+)+(?::([0-9]+))} [qc::conn_host] -> port] } {
            return $port
        } else {
            return [expr {[qc::conn_protocol] eq "http" ? "80" : "443"}]
        }
    }
}

proc qc::conn_host { } {
    #| Return the host indicated in the HTTP/1.1 headers
    set conn_headers [ns_conn headers]

    set host [ns_set iget $conn_headers Host]
    if { $host eq "" } {
        # Fallback to NaviServer supplied value which could fallback to driver default
        # TODO Preserves legacy
        if { [regexp {^https?://([a-z0-9_][a-z0-9_\-]*(?:\.[a-z0-9_\-]+)+(?::[0-9]+)?)} [ns_conn location] -> host] } {
            return $host
        } else {
            error "conn_host: Cannot determine host"
        }
    } else {
        return $host
    }
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
