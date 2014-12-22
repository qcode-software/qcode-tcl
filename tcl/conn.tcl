namespace eval qc {
    namespace export conn_* is_*
}

proc qc::conn_remote_ip {} {
    #| Try to return the remote IP address of the current connection
    #| Trust that a reverse proxy like nginx is setup to pass an X-Forwarded-For header.
    set headers [ns_conn headers]
    if { [ns_set find $headers X-Forwarded-For]!=-1 && ([eq [ns_conn peeraddr] 127.0.0.1] || [string match  192.168* [ns_conn peeraddr]] ||  [eq [ns_conn peeraddr] [ns_info address]]) } {
	# Proxied so trust X-Forwarded-For
	set forwarded [ns_set iget $headers X-Forwarded-For]
	set ip $forwarded
    } else {
	set ip [ns_conn peeraddr]
    }
    return $ip
}

proc qc::conn_marshal { {error_handler qc::error_handler} {namespace ""} } {
    #| Look for a proc with a leading slash like /foo.html that matches the incoming request url. 
    #| If found call the proc with values from form variables that match the proc's argument names.
    #| The request suffix is used to decide which error handler to use.
    #| If no matching proc exists then try to return a file or a 404 not found.

    if { [info exists ::env(ENVIRONMENT)] && $::env(ENVIRONMENT) ne "LIVE" } {
	qc::reload
    }
    if { $error_handler eq "" } {
	set error_handler qc::error_handler
    }
    set url [ns_conn url]
    set file [ns_url2file [ns_conn url]]
    
    if { [llength [info procs "${namespace}::${url}"]] } {
	qc::try {
	    set result [form_proc "${namespace}::${url}"]
	    if { ![expr 0x1 & [ns_conn flags]] } {
		# If conn is still open
		set content-type "[mime_type_guess [file tail $url]]; charset=utf-8"
		ns_return 200 ${content-type} $result
	    }
	} {
	    $error_handler 
	}
    } elseif { [file exists $file] } {
        set outputheaders [ns_conn outputheaders]
        set file_mtime [file mtime $file]
        if { $file_mtime > [qc::cast_epoch now] } {
            # Last-Modified should never be in the future
            set last_modified [qc::format_timestamp_http [qc::cast_epoch now]]
        } else {
            set last_modified [qc::format_timestamp_http $file_mtime]
        }
        ns_set put $outputheaders "Last-Modified" $last_modified
    
        set if_modified_since [qc::conn_if_modified_since]
        if { [qc::is_timestamp_http $if_modified_since]
             && $file_mtime <= [clock scan $if_modified_since] } {
            ns_return 304 {} {}
        } else {
	    ns_returnfile 200 [ns_guesstype $file] $file
        }
    } else {
        qc::try {
            error "Page not found." {} NOT_FOUND
        } {
            $error_handler 
        }
    }
}

proc qc::conn_url {} {
    #| Try to construct the full url of this request.
    return "[qc::conn_location][ns_conn url]"
}

proc qc::conn_location {} {
    #| Try to construct the location
    set port [ns_set iget [ns_conn headers] Port]
    set host [ns_set iget [ns_conn headers] Host]

    if { $host ne "" && $port ne "" } {
        # Proxied through nginx
	if { [eq $port 80] } {
	    return "http://$host"
	} elseif { [eq $port 443] } {
	    return "https://$host"
	} elseif { [eq $port 8443] } {
	    return "https://$host:8443"
	} else  {
	    return "http://$host:$port"
	}
    } else {
        # Not proxied
	return [ns_conn location]
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
    set ui_string [ns_set get $header_set "User-Agent"]
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

proc qc::conn_path {} {
    #| Return the path of the current connection
    # Note: using "ns_conn url" instead of "ns_conn request" as the latter is not updated for "ns_internalredirect"
    return [ns_conn url]
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
    if { [ns_set find $headers If-Modified-Since]!=-1 } {
        return [lindex [split [ns_set iget [ns_conn headers] If-Modified-Since] ";"] 0]
    } else {
        return ""
    }
}

proc qc::conn_open {} {
    #| Check if the client connection is open
    return [expr {[ns_conn isconnected] && !(0x1 & [ns_conn flags])}]
}