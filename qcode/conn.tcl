package provide qcode 1.2
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

doc conn_remote_ip {
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

    if { [string equal [info procs $url] $url] || [string equal [info procs "::$url"] "::$url"] } {
	try {
	    form_proc $url
	} {
	    $error_handler 
	}
    } elseif { [file exists $file] } {
	ns_returnfile 200 [ns_guesstype $file] $file
    } else {
	ns_returnnotfound
    }
}

doc conn_marshal {
    Examples {
	# We can use ns_register_proc to get conn_marshal to handle .html requests with
	% ns_register_proc GET  /*.html conn_marshal
	% ns_register_proc POST /*.html conn_marshal
	% ns_register_proc HEAD /*.html conn_marshal
	
	# If we then create a proc
	proc /foo.html {greeting name} {
	    return_html "You said $greeting $name"
	}
	# a request for /foo.html?greeting=Hello&name=John would result in a call to 
	/foo.html Hello John
	# and return "You said Hello John"
    }
}

proc qc::conn_url {} {
    set port [ns_set iget [ns_conn headers] Port]
    set host [ns_set iget [ns_conn headers] Host]
    if { [ne $host ""] } {
	if { [eq $port 443] } {
	    return "https://$host[ns_conn url]"
	} elseif { [eq $port 8443] } {
	    return "https://$host:8443[ns_conn url]"
	} else {
	    return "http://$host[ns_conn url]"
	}
    } else {
	return [ns_conn url]
    }
}
 
# Alexey Pechnikov
proc _ns_conn {args} {
    set host [string tolower [ns_set get [ns_conn headers] Host]]
    if {[string match [lindex $args 0] "host"]} {
	regexp {[^:]+} $host host
	return $host
    } elseif {[string match [lindex $args 0] "server"]} {
	regexp {[^:\.]+} $host host
	return $host
    } elseif {[string match [lindex $args 0] "port"]} {
	if { [regexp {:(\d+)} $host str port] == 1 } {
	    return $port
	}
	return
    } elseif {[string match [lindex $args 0] "protocol"]} {
	if {[string equal [ns_set get [ns_conn headers] "X-Forwarded-Proto"] "https"]} {
	    return https
	}
	return http
    } elseif {[string match [lindex $args 0] "location"]} {
	return [ns_conn protocol]://$host
    } else {
	return [_ns_conn {*}$args]
    }
}