namespace eval qc {
    namespace export return2client return_*
}

proc qc::return2client { args } {
    #| Return data to http client if a connection is open otherwise just output the given content.
    # Usage return2client ?code code? ?content-type mime-type? ?html html? ?text text? ?xml xml? ?json json? ?csv csv? ?file file? ?filename filename? ?download boolean? ?filter_cc boolean? ?header header? .. 
    set arg_names [qc::args2vars $args]
    set headers [lexclude $arg_names html xml text json csv file filename download code content-type filter_cc]
    default code 200
    default filter_cc no
    default filename [string trimleft [qc::url_path [ns_conn url]] /]

    # Determine type of payload and configure defaults
    if { [info exists file] } {
        # File
        default download yes
        default content-type [qc::mime_type_guess $filename]
        set var file
    } elseif { [info exists html] } {
        # HTML payload
        default download no
	default content-type "text/html; charset=utf-8"
	set var html
    } elseif { [info exists xml] } {
        # XML payload
        default download no
	default content-type "text/xml; charset=utf-8"
	set var xml
    } elseif { [info exists text] } {
        # Text payload
        default download no
	default content-type "text/plain; charset=utf-8"
	set var text
    } elseif { [info exists csv] } {
        # CSV payload
        default download yes
	default content-type "text/csv; charset=utf-8"
	set var csv
    } elseif { [info exists json] } {
        # JSON payload
        default download no
	default content-type "application/json; charset=utf-8"
	set var json
    } else {
        # Unknown payload
	error "No payload given in html or xml or text or json or file" 
    }

    # Content-Disposition
    if { $download } {
        # Download payload as an attachment
        default content-disposition "attachment; filename=$filename"
    } else {
        # Display payload inline
        default content-disposition "inline; filename=$filename"
    }
    if { "content-disposition" ni $headers } {
        lappend headers content-disposition       
    }    

    # Mask plain text credit card numbers in payload
    if { $filter_cc && $var ne "file" } {
        set $var [qc::format_cc_masked_string [set $var]] 
    }
    
    if { [expr 0x1 & [ns_conn flags]] } {
        # no open connection - just return payload
        return [set $var]
    } else {
        # Client is still connected        
        
        # Update headers
        foreach name $headers {
            set conn_headers [ns_conn outputheaders]
            ns_set update $conn_headers $name [set $name]
        }

        # Return payload to client
        if { $var eq "file" } {
            ns_returnfile $code ${content-type} [set $var]
        } else {
            ns_return $code ${content-type} [set $var]
        }
    }
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
        # Relative url

        if { $port ne "" && $host ne ""} {
            # Port and host specified in headers (or by proxy)
            set next_url [string trimleft $next_url /]
            if { [eq $port 80] } {
                set next_url "http://$host/$next_url"
            } elseif { [eq $port 443] } {
                set next_url "https://$host/$next_url"
            } elseif { [eq $port 8443] } {
                set next_url "https://$host:8443/$next_url"
            } else  {
                set next_url "http://$host:$port/$next_url"
            } 

            # check for malicious mal-formed url
            if { ![is_url $next_url] } {
                error "\"[html_escape $next_url]\" is not a valid url."
            }
         
        } else {
            # Port or host unspecified, so just check that it's a valid relative url and pass to ns_returnredirect
            if { ! [is_url -relative $next_url] } {
                error "\"[html_escape $next_url]\" is not a valid url."
            }
        }

    } else {
        # Absolute url
        # check that redirection is to the same domain
        if { ![regexp "^https?://${host}(:\[0-9\]+)?(/|\$)" $next_url] } {
            error "Will not redirect to a different domain. Host $host. Redirect to $next_url"
        }
        # check for malicious mal-formed url
        if { ![is_url $next_url] } {
            error "\"[html_escape $next_url]\" is not a valid url."
        }
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
