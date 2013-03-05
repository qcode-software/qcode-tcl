package provide qcode 1.17
package require doc
namespace eval qc {}

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

doc qc::conn_remote_ip {
    Examples {
	% conn_remote_ip
	12.34.56.78
    }
}

proc qc::conn_marshal { {error_handler qc::error_handler} } {
    #| Look for a proc with a leading slash like /foo.html that matches the incoming request url. 
    #| If found call the proc with values from form variables that match the proc's argument names.
    #| The request suffix is used to decide which error handler to use.
    #| If no matching proc exists then try to return a file or a 404 not found.
    if { [param_exists testing] && [param testing] } {
	qc::reload
    }
    if { $error_handler eq "" } {
	set error_handler qc::error_handler
    }
    set url [ns_conn url]
    set file [ns_url2file [ns_conn url]]

    if { [llength [info procs "::$url"]] } {
	try {
	    set result [form_proc ::$url]
	    if { ![expr 0x1 & [ns_conn flags]] } {
		# If conn is still open
		set content-type "[mime_type_guess [file tail $url]]; charset=utf-8"
		ns_return 200 ${content-type} $result
	    }
	} {
	    $error_handler 
	}
    } elseif { [file exists $file] } {
	ns_returnfile 200 [ns_guesstype $file] $file
    } else {
	ns_returnnotfound
    }
}

doc qc::conn_marshal {
    Examples {
	# We can use ns_register_proc to get conn_marshal to handle .html requests with
	% ns_register_proc GET  /*.html conn_marshal
	% ns_register_proc POST /*.html conn_marshal
	% ns_register_proc HEAD /*.html conn_marshal
	
	# If we then create a proc
	proc /foo.html {greeting name} {
	    return "You said $greeting $name"
	}
	# a request for /foo.html?greeting=Hello&name=John would result in a call to 
	/foo.html Hello John
	# and return "You said Hello John"
    }
}

proc qc::conn_url {} {
    #| Try to construct the full url of this request.
    set port [ns_set iget [ns_conn headers] Port]
    set host [ns_set iget [ns_conn headers] Host]
    if { [ne $host ""] } {
	if { [eq $port 80] } {
	    return "http://$host[ns_conn url]"
	} elseif { [eq $port 443] } {
	    return "https://$host[ns_conn url]"
	} elseif { [eq $port 8443] } {
	    return "https://$host:8443[ns_conn url]"
	} else  {
	    return "http://$host:$port[ns_conn url]"
	}
    } else {
	return [ns_conn url]
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
    if [regexp {[\s;]MSIE\s([1-9][0-9]*)\.[0-9]+[bB]?;} $ui_string -> version] {
	return true
    } else {
	return false
    }
}