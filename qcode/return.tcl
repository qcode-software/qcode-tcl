package provide qcode 1.7
package require doc
namespace eval qc {}

proc qc::return2client { args } {
    #| Return data to http client
    # Usage return2client ?code code? ?content-type mime-type? ?html html? ?text text? ?xml xml? ?json json? ?filter_cc boolean? ?header header? .. 
    set arg_names [args2vars $args]
    if { [info exists html] } {
	default content-type "text/html; charset=utf-8"
	set var html
    } elseif { [info exists xml] } {
	default content-type "text/xml; charset=utf-8"
	set var xml
    } elseif { [info exists text] } {
	default content-type "text/plain; charset=utf-8"
	set var text
    } elseif { [info exists json] } {
	default content-type "application/json; charset=utf-8"
	set var json
    } else {
	error "No payload given in html or xml or text or json" 
    }
    default code 200
    default filter_cc no
    if { $filter_cc } {
	# mask credit card numbers
	set $var [qc::format_cc_masked_string [set $var]] 
    }
    # Other headers
    foreach name [lexclude $arg_names html xml text json code content-type] {
    	set headers [ns_conn outputheaders]
	ns_set update $headers $name [set $name]
    }
    ns_return $code ${content-type} [set $var]
}

proc qc::return_html { html } { 
    # Deprecated
    return2client html $html
}

proc qc::return_xml { xml } {
    # Deprecated
    return2client xml $xml
}

proc qc::return_csv { text } { 
    return2client content-type "text/csv; charset=utf-8" text $text Content-disposition "attachment;"
}

proc qc::return_soap { string } { 
    ns_return 200 "application/soap+xml; charset=utf-8" $string
}

proc qc::return_headers {} {
    set list {}
    lappend list "HTTP/1.0 200 OK"
    lappend list "Date: [ns_httptime [clock seconds]]"
    lappend list "MIME-Version: 1.0"
    lappend list "Content-Type: text/html"
    ns_write [join $list \r\n]
    ns_write \r\n\r\n
}

proc qc::return_headers_chunked {} {
    set list {}
    lappend list "HTTP/1.1 200 OK"
    lappend list "Date: [ns_httptime [clock seconds]]"
    lappend list "MIME-Version: 1.0"
    lappend list "Content-Type: text/html"
    lappend list "Transfer-Encoding: chunked"
    ns_write [join $list \r\n]
    ns_write \r\n\r\n
}

proc qc::return_chunks {string} {
    regsub -all {\r\n} $string \n string
    foreach line [split $string \n] {
	qc::return_chunk $line
    }
}

proc qc::return_chunk {string} {
    ns_write [format %X [string bytelength $string]]\r\n$string\r\n
}

proc qc::return_next { next_url } {   
    #| Redirect to an internal url
    set port [ns_set iget [ns_conn headers] Port]
    set host [ns_set iget [ns_conn headers] Host]
    if { ![regexp {^https?://} $next_url] } {
	set next_url [string trimleft $next_url /]
	if { [ne $host ""] } {
	    if { [eq $port 80] || [eq $port ""] } {
		set next_url "http://$host/$next_url"
	    } elseif { [eq $port 443] } {
		set next_url "https://$host/$next_url"
	    } elseif { [eq $port 8443] } {
		set next_url "https://$host:8443/$next_url"
	    } else  {
		set next_url "http://$host:$port/$next_url"
	    }
	}
    }
    # check that redirection is to the same domain
    if { ![regexp "^https?://${host}(:\[0-9\]+)?(/|\$)" $next_url] } {
	error "Will not redirect to a different domain. Host $host. Redirect to $next_url"
    }
    # check for malicious mal-formed url
    if { ![is_url $next_url] } {
	error "\"[html_escape $next_url]\" is not a valid url."
    }
    ns_returnredirect $next_url
}

proc ns_returnmoved {url} {
    ns_set update [ns_conn outputheaders] Location $url
    ns_return 301 "text/html" [subst \
  {<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
  <HTML>
  <HEAD>
  <TITLE>Moved</TITLE>
  </HEAD>
  <BODY>
  <H2>Moved</H2>
  <A HREF="$url">The requested URL has moved here.</A>
  <P ALIGN=RIGHT><SMALL><I>[ns_info name]/[ns_info patchlevel] on [ns_conn location]</I></SMALL></P>
  </BODY></HTML>}]
}


