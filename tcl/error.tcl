namespace eval qc {
    namespace export error_handler error_report error_report_*
}

proc qc::error_handler {{error_message "NULL"} args} {
    #| Return custom error responses depending value of error_code.
    # Pass in error message, info and code if available
    # Otherwise will take a copy of the global error* variables for backward compatiblity
    if { [llength $args] == 2 } {
        set error_info [lindex $args 0]
        set error_code [lindex $args 1]
    } elseif { [llength $args] == 1 } {
        set error_info [dict get [lindex $args 0] -errorinfo]
        set error_code [dict get [lindex $args 0] -errorcode]
    } else {
        return -code error "Usage: qc::error_handler ?error_message? ?(error_info error_code | options)?"
    }
    
    default error_info "NULL" error_code "NULL"
    foreach {local_var global_var} [list error_message errorMessage error_info errorInfo error_code errorCode ] {
        if { [set $local_var] eq "NULL" } {
            global $global_var
            set $local_var [set $global_var]
        }
    }

    set mime_types [list "text/html" "application/json" "application/xml" "text/xml"]
    set mime_type [qc::http_content_negotiate $mime_types]
    set media_type [lindex [split $mime_type "/"] 1]
    if { $media_type eq "" } {
        # Couldn't negotiate an acceptable response type.
        return [return2client code 406 text "Couldn't respond with an acceptable content type. Available content types: [join $mime_types ", "]"]
    }
    
    switch -glob -- $error_code {
	USER* {
	    switch $media_type {
                xml {
                    set body [qc::xml error $error_message]
                }
                json {
                    qc::response status invalid
                    qc::response message error $error_message
                    set body [response2json]
                }
                * -
                html {
                    set media_type html
                    set title "Missing or Invalid Data"
                    set head [h head [h title $title]]
                    set contents [h h2 $title]
                    append contents [h hr]
                    append contents $error_message
                    append contents [h p "Please back up and try again."]
                    append contents [h hr]
                    set body [h html "${head}[h body $contents]"]
                }
            }
            return [return2client code 200 $media_type $body filter_cc yes]
        }
        PERM* {
            switch $media_type {
                xml {
                    set body [qc::xml error "Not Authorised: $error_message"]
                }
                json {
                    qc::response status invalid
                    qc::response message error "Not Authorised: $error_message"
                    set body [response2json]
                }
                * -
                html {
                    set media_type html
                    set body [h p "Not Authorised: $error_message"]
                }
            }
            return [return2client code 401 $media_type $body]
        }
        AUTH* {
            switch $media_type {
                xml {
                    set body [qc::xml error "Authentication Failed: $error_message"]
                }
                json {
                    qc::response status invalid
                    qc::response message error "Authentication Failed: $error_message"
                    set body [response2json]
                }
                * -
                html {
                    set media_type html
                    set body [h p "Authentication Failed: $error_message"]
                }
            }
            return [return2client code 401 $media_type $body]
        }
        NOT_FOUND* {
            switch $media_type {
                xml {
                    set body [qc::xml error "Not Found: $error_message"]
                }
                json {
                    qc::response status invalid
                    qc::response message error "Not Found: $error_message"
                    set body [response2json]
                }
                * -
                html {
                    set media_type html
                    set body [h p "Not Found: $error_message"]
                }
            }
            return [return2client code 404 $media_type $body]
        }
        BAD_REQUEST* {
            switch $media_type {
                xml {
                    set body [qc::xml error "Bad Request: $error_message"]
                }
                json {
                    qc::response status invalid
                    qc::response message error "Bad Request: $error_message"
                    set body [response2json]
                }
                * -
                html {
                    set media_type html
                    set body [h p "Bad Request: $error_message"]
                }
            }
            return [return2client code 400 $media_type $body]
        }
	default {
	    log Error $error_info
            if {  [info exists ::env(ENVIRONMENT)] && $::env(ENVIRONMENT) ne "LIVE" } {
                switch $media_type {
                    xml {
                        set body [qc::xml error "Software Bug - [string range $error_message 0 75]"]
                    }
                    json {
                        qc::response status invalid
                        qc::response message error "Software Bug - [string range $error_message 0 75]"
                        set body [response2json]
                    }
                    * -
                    html {
                        set media_type html
                        set body [qc::error_report $error_message $error_info $error_code]
                    }
                }
            } else {
	        # LIVE
                switch $media_type {
                    xml {
                        set body [qc::xml error "Internal Server Error. An email report has been sent to our engineers"]
                    }
                    json {
                        qc::response status invalid
                        qc::response message error "Internal Server Error. An email report has been sent to our engineers"
                        set body [response2json]
                    }
                    * -
                    html {
                        set media_type html
                        set body [h h2 "Internal Server Error"]
                        append body [h p "An email report has been sent to our engineers."]
                    }
                }
            }

            return2client code 500 $media_type $body filter_cc yes
            
	    if { [qc::param_exists email_support] } {
		set subject "[string toupper [ns_info server]] Bug - [string range $error_message 0 75]"
		qc::email_support subject $subject html [qc::error_report $error_message $error_info $error_code] 
	    }
	}
    }
}

proc qc::error_report {{error_message "NULL"} {error_info "NULL"} {error_code "NULL"}} {
    #| Return html error report. If there was a http connection when error occurred report any 
    #| relevant information about http request.
    # Pass in error message, info and code if available
    # Otherwise will take a copy of the global error* variables for backward compatiblity
    foreach {local_var global_var} [list error_message errorMessage error_info errorInfo error_code errorCode ] {
        if { [set $local_var] eq "NULL" } {
            global $global_var
            set $local_var [set $global_var]
        }
    }
    if { [ns_conn isconnected] } {
	sset html {
	    <html>
	    <h2>Software Bug</h2>
	    An error has occurred while processing your request.
	    <p>
	    <b>hostname:</b>[ns_info hostname]<br>
	    <b>url:</b>[html_escape [qc::conn_path]]<br>
	    <b>request:</b>[html_escape [ns_conn request]]<br>
	    <b>remoteip:</b>[qc::conn_remote_ip]<br>
	    <b>time:</b>[qc::format_timestamp now]<br>
	    <b>errorMessage:</b> [html_escape $error_message]<br>
	    <b>errorInfo:</b> <pre>[html_escape $error_info]</pre><br>
	    <b>errorCode:</b> $error_code
	    <p>
	    <h3>Form Variables:</h3>
	    [qc::error_report_form_vars]
	    <h3>Cookies</h3>
	    [qc::error_report_cookies]
            <h3>HTTP Headers</h3>
            [qc::error_report_headers]
	    </html>
	}
    } else {
	sset html {
	    <html>
	    <h2>Software Bug</h2>
	    <p>
	    <b>hostname:</b>[ns_info hostname]<br>
	    <b>time:</b>[qc::format_timestamp now]<br>
	    <b>errorMessage:</b> [html_escape $error_message] <br>
	    <b>errorInfo:</b> <pre>[html_escape $error_info]</pre><br>
	    <b>errorCode:</b> $error_code
	    <p>
	    </html>
	}
    }
    return $html
}

proc qc::error_report_no_conn { message info code } {
    #| Return html error report, used when there was no http connection when error occurred.
    
    set html {
        <html>
        <h2>Software Bug</h2>
        <p>
        <b>hostname:</b>[ns_info hostname]<br>
        <b>time:</b>[qc::format_timestamp now]<br>
        <b>errorMessage:</b> $message <br>
        <b>errorInfo:</b> <pre>[html_escape $info]</pre><br>
        <b>errorCode:</b> $code
        <p>
        </html>
    }
    return [subst $html]
}

proc qc::error_report_form_vars {} {
    #| Return preformated html indicating values of all form variables when error occurred.
  
    set set_id [ns_getform]
    if { [string equal $set_id ""] } {
	set size 0
    } else {
	set size [ns_set size $set_id]
    } 
    set report {}
    set i 0
    while {$i<$size} {
	set name [ns_set key $set_id $i]
	# mask anything that looks like a card number.
	set value [ns_set value $set_id $i]
	append report "<b>$name</b>\n"
	# Truncate value if too long
	if { [string bytelength $value] > 1024 } {
	    append report "<pre>[string range $value 0 1023]....</pre>"
	} else {
	    append report <pre>$value</pre>
	}
	append report \n
        incr i
    }
    return $report
}

proc qc::error_report_locals {} {
    #| Return preformated html indicating values of all local variables when error occurred.
   
    set report {}
    foreach name [uplevel 1 {info locals}] {
	# mask anything that looks like a card number.
	set value [upset 1 $name]
	append report "<b>$name</b>\n"
	# Truncate value if too long
	if { [string bytelength $value] > 1024 } {
	    append report "<pre>[string range $value 0 1023]....</pre>"
	} else {
	    append report <pre>$value</pre>
	}
	append report \n
    }
    return $report
}

proc qc::error_report_cookies {} {
    set headers [ns_conn headers]
    set cookies [ns_set iget $headers Cookie]
    set report {}
    foreach pair [split $cookies ;] {
	lassign [split $pair =] name value
	set name [qc::url_decode $name]
	set value [string trimright $value "; "]
	set value [qc::url_decode $value]
	append report "<b>$name</b> $value <br>"
    }
    return $report
}

proc qc::error_report_headers {} {
    set headers [ns_conn headers]
    set report {}
    foreach {name value} [ns_set array $headers] {
	append report "[h b $name]: [h span $value]<br>"
    }
    return $report
}
