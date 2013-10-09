package provide qcode 2.0
package require doc
namespace eval qc {}

proc qc::error_handler { } {
    #| Return custom error responses depending value of errorCode.
    
    set suffix [file extension [ns_conn url]]
    global errorMessage errorList errorInfo errorCode
    switch -glob -- $errorCode {
	USER* {
	    if { [eq $suffix .xml] } {
		return2client xml [qc::xml error $errorMessage] filter_cc yes
	    } elseif { [eq $suffix .json] } {
		return2client code 409 json $errorMessage
	    } else {
		set html {
		    <h2>Missing or Invalid Data</h2>
		    <hr>
		    $errorMessage
		    <p>
		    Please back up and try again.
		    <hr>
		}
		return2client html [subst $html] filter_cc yes
	    }
	}
        PERM* {
	    if { [eq $suffix .xml] } {
		return2client xml [qc::xml error "Not authorized:$errorMessage"]
	    } else {
		return2client code 401 html "Not Authorized:$errorMessage"
	    }
        }
        AUTH* {
	    if { [eq $suffix .xml] } {
		return2client xml  [qc::xml error "Authentication Failed:$errorMessage"]
	    } else {
		return2client code 401 html "Authentication Failed:$errorMessage"
	    }
        }
	default {
	    log Error $errorInfo
            if {  [eq $suffix .xml] && [info exists ::env(ENVIRONMENT)] && $::env(ENVIRONMENT) ne "LIVE" } {
                return2client xml [qc::xml error "Software Bug - [string range $errorMessage 0 75]"] filter_cc yes
            } elseif { [eq $suffix .xml] } {
                # LIVE
                return2client xml [qc::xml error "Internal Server Error. An email report has been sent to our engineers"] filter_cc yes
	    } elseif { [info exists ::env(ENVIRONMENT)] && $::env(ENVIRONMENT) ne "LIVE" } {
                return2client code 500 html [qc::error_report] filter_cc yes
            } else {
	        # LIVE
                return2client code 500 html [html h2 "Internal Server Error"][html p "An email report has been sent to our engineers."] filter_cc yes
            }
	    
	    if { [qc::param_exists email_support] } {
		set subject "[string toupper [ns_info server]] Bug - [string range $errorMessage 0 75]"
		email_support subject $subject html [qc::error_report] 
	    }
	}
    }
}

proc qc::error_report {} {
    #| Return html error report. If there was a http connection when error occurred report any 
    #| relevant information about http request.
    
    global errorMessage errorInfo errorCode
    # Copy error globals in case they are clobbered before we report them
    set error_message $errorMessage
    set error_info $errorInfo
    set error_code $errorCode
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
	    <b>time:</b>[qc::format_timestamp now]<br>
	    <b>errorMessage:</b> $error_message <br>
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
	    <b>errorMessage:</b> $error_message <br>
	    <b>errorInfo:</b> <pre>[html_escape $error_info]</pre><br>
	    <b>errorCode:</b> $error_code
	    <p>
	    </html>
	}
    }
    return $html
}

proc qc::error_report_no_conn {} {
    #| Return html error report, used when there was no http connection when error occurred.
   
    global errorMessage errorInfo errorCode
     
    set html {
        <html>
        <h2>Software Bug</h2>
        <p>
        <b>hostname:</b>[ns_info hostname]<br>
        <b>time:</b>[qc::format_timestamp now]<br>
        <b>errorMessage:</b> $errorMessage <br>
        <b>errorInfo:</b> <pre>[html_escape $errorInfo]</pre><br>
        <b>errorCode:</b> $errorCode
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

