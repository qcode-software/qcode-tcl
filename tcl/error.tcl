namespace eval qc {
    namespace export error_handler error_report error_report_*
}

proc qc::error_handler {{error_message "NULL"} {error_info "NULL"} {error_code "NULL"}} {
    #| Return custom error responses depending value of error_code.
    # Pass in error message, info and code if available
    # Otherwise will take a copy of the global error* variables for backward compatiblity
    foreach {local_var global_var} [list error_message errorMessage error_info errorInfo error_code errorCode ] {
        if { [set $local_var] eq "NULL" } {
            global $global_var
            set $local_var [set $global_var]
        }
    }
    
    set suffix [file extension [ns_conn url]]
    switch -glob -- $error_code {
	USER* {
	    if { [eq $suffix .xml] } {
		return2client xml [qc::xml error $error_message] filter_cc yes
	    } elseif { [eq $suffix .json] } {
		return2client code 409 json $error_message
	    } else {
		set html {
		    <h2>Missing or Invalid Data</h2>
		    <hr>
		    $error_message
		    <p>
		    Please back up and try again.
		    <hr>
		}
		return2client html [subst $html] filter_cc yes
	    }
	}
        PERM* {
	    if { [eq $suffix .xml] } {
		return2client xml [qc::xml error "Not authorized:$error_message"]
	    } else {
		return2client code 401 html "Not Authorized:$error_message"
	    }
        }
        AUTH* {
	    if { [eq $suffix .xml] } {
		return2client xml  [qc::xml error "Authentication Failed:$error_message"]
	    } else {
		return2client code 401 html "Authentication Failed:$error_message"
	    }
        }
        NOT_FOUND* {
            return2client code 404 html "Not Found:$error_message"
        }
        BAD_REQUEST* {
            return2client code 400 html "Bad Request:$error_message"
        }
	default {
	    log Error $error_info
            if {  [eq $suffix .xml] && [info exists ::env(ENVIRONMENT)] && $::env(ENVIRONMENT) ne "LIVE" } {
                return2client xml [qc::xml error "Software Bug - [string range $error_message 0 75]"] filter_cc yes
            } elseif { [eq $suffix .xml] } {
                # LIVE
                return2client xml [qc::xml error "Internal Server Error. An email report has been sent to our engineers"] filter_cc yes
	    } elseif { [info exists ::env(ENVIRONMENT)] && $::env(ENVIRONMENT) ne "LIVE" } {
                return2client code 500 html [qc::error_report2 $error_message $options] filter_cc yes
            } else {
	        # LIVE
                return2client code 500 html [html h2 "Internal Server Error"][html p "An email report has been sent to our engineers."] filter_cc yes
            }
	    
	    if { [qc::param_exists email_support] } {
		set subject "[string toupper [ns_info server]] Bug - [string range $error_message 0 75]"
		qc::email_support subject $subject html [qc::error_report2 $error_message $options] 
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
	    <b>url:</b>[html_escape [ns_conn url]]<br>
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
