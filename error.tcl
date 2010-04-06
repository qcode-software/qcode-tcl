proc qc::error_handler { } {
    set suffix [file extension [ns_conn url]]
    global errorMessage errorList errorInfo errorCode
    switch -glob -- $errorCode {
	USER* {
	    if { [eq $suffix .xml] } {
		ns_return 200 text/xml [qc::xml error $errorMessage]
	    } else {
		set html {
		    <h2>Missing or Invalid Data</h2>
		    <hr>
		    $errorMessage
		    <p>
		    Please back up and try again.
		    <hr>
		}
		ns_return 200 text/html [subst $html]
	    }
	}
        PERM* {
	    if { [eq $suffix .xml] } {
		ns_return 200 text/xml [qc::xml error "Not authorized:$errorMessage"]
	    } else {
		ns_return 401 text/html "Not Authorized:$errorMessage"
	    }
        }
        AUTH* {
	    if { [eq $suffix .xml] } {
		ns_return 200 text/xml [qc::xml error "Authentication Failed:$errorMessage"]
	    } else {
		ns_return 401 text/html "Authentication Failed:$errorMessage"
	    }
        }
	default {
	    ns_log Error $errorInfo
	    if { [eq $suffix .xml] } {
		ns_return 200 text/xml [qc::xml error "Software Bug - [string range $errorMessage 0 75]"]
	    } else {
		ns_return 500 text/html [qc::error_report]	
	    }
	    if { [qc::param_exists email_support] } {
		set subject "Bug [string range $errorMessage 0 75]"
		qc::email_html "nsd@[ns_info hostname]" [qc::param email_support] $subject [qc::error_report]
	    }
	}
    }
}

proc qc::error_report {} {
    global errorMessage errorInfo errorCode
    if { [ns_conn isconnected] } {
	sset html {
	    <html>
	    <h2>Software Bug</h2>
	    An error has occurred while processing your request.
	    <p>
	    <b>hostname:</b>[ns_info hostname]<br>
	    <b>url:</b>[ns_conn url]<br>
	    <b>request:</b>[ns_conn request]<br>
	    <b>remoteip:</b>[qc::conn_remote_ip]<br>
	    <b>time:</b>[clock format [ns_time]]<br>
	    <b>errorMessage:</b> $errorMessage <br>
	    <b>errorInfo:</b> <pre>[ns_quotehtml $errorInfo]</pre><br>
	    <b>errorCode:</b> $errorCode
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
	    <b>time:</b>[clock format [ns_time]]<br>
	    <b>errorMessage:</b> $errorMessage <br>
	    <b>errorInfo:</b> <pre>[ns_quotehtml $errorInfo]</pre><br>
	    <b>errorCode:</b> $errorCode
	    <p>
	    </html>
	}
    }
    return $html
}

proc qc::error_report_no_conn {} {
    global errorMessage errorInfo errorCode
    set html {
        <html>
        <h2>Software Bug</h2>
        <p>
        <b>hostname:</b>[ns_info hostname]<br>
        <b>time:</b>[clock format [ns_time]]<br>
        <b>errorMessage:</b> $errorMessage <br>
        <b>errorInfo:</b> <pre>[ns_quotehtml $errorInfo]</pre><br>
        <b>errorCode:</b> $errorCode
        <p>
        </html>
    }
    return [subst $html]
}

proc qc::error_report_form_vars {} {
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
    set report {}
    foreach name [uplevel 1 {info locals}] {
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
	set name [ns_urldecode $name]
	set value [string trimright $value "; "]
	set value [ns_urldecode $value]
	append report "<b>$name</b> $value <br>"
    }
    return $report
}
