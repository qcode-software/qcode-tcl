namespace eval qc {
    namespace export return2client return_*
}

proc qc::return2client { args } {
    #| Return data to http client.
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

proc qc::return_html { html } { 
    # Deprecated
    return2client html $html
}

proc qc::return_xml { xml } {
    # Deprecated
    return2client xml $xml
}

proc qc::return_csv { text } { 
    return2client content-type "text/csv; charset=utf-8" text $text content-disposition "attachment;"
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
    set output [join $list \r\n]
    append output \r\n\r\n
    ns_write $output
}

proc qc::return_headers_chunked {} {
    set list {}
    lappend list "HTTP/1.1 200 OK"
    lappend list "Date: [ns_httptime [clock seconds]]"
    lappend list "MIME-Version: 1.0"
    lappend list "Content-Type: text/html"
    lappend list "Transfer-Encoding: chunked"
    set output [join $list \r\n]
    append output \r\n\r\n
    ns_write $output
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

proc qc::return_next { args } {
    #| Redirect to an internal url
    qc::args $args -conn_protocol ? -conn_host ? -conn_port ? -- next_url

    if { ![info exists conn_protocol] } {
        set conn_protocol [ns_conn protocol]
    }
    if { ![info exists conn_host] } {
        set conn_host [ns_set iget [ns_conn headers] Host]
    }
    if { ![info exists conn_port] } {
        set conn_port [ns_set iget [ns_conn headers] Port]
    }

    if { ![regexp {^https?://} $next_url] } {
        # Relative url
        
        set next_url [string trimleft $next_url /]
        set next_url "[qc::conn_location \
                        -conn_protocol  $conn_protocol \
                        -conn_host      $conn_host \
                        -conn_port      $conn_port \
                      ]/$next_url"

        # check for malicious mal-formed url
        if { ![qc::is url $next_url] } {
            error "\"[html_escape $next_url]\" is not a valid url."
        }

    } else {
        # Absolute url
        # check that redirection is to the same domain
        if { ![regexp "^https?://${conn_host}(:\[0-9\]+)?(/|\$)" $next_url] } {
            error "Will not redirect to a different domain. Host $conn_host. Redirect to $next_url"
        }
        # check for malicious mal-formed url
        if { ![qc::is url $next_url] } {
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

proc qc::return_response {args} {
    #| Returns the global data structure to the client.
    #| Content negotiates to try and find a suitable content type.
    qc::args $args -code 200 -response2html qc::response2html -- args
    
    set mime_types [list "text/html" "application/json" "application/xml" "text/xml"]
    set mime_type [qc::http_accept_header_best_mime_type $mime_types]
    set media_type [lindex [split $mime_type "/"] 1]
    if { $media_type eq "" } {
        # Couldn't negotiate an acceptable response type.
        return [qc::return2client code 406 text "Couldn't respond with an acceptable content type. Available content types: [join $mime_types ", "]"]
    }
    
    switch -nocase -- $media_type {
        xml {
            set response [qc::response2xml]
        }
        json {
            set response [qc::response2json]
        }
        * -
        html {
            set media_type html
            set response [$response2html]           
        }
    }

    qc::return2client code $code $media_type $response
}
