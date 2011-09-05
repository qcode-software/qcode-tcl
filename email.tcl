package require mime
package require base64 
package require uuid

doc email {
    Title "Sending Email"
    Description {
	All of these procs call [doc_link sendmail] (which is based on ns_sendmail) and connects directly to an SMTP socket normally 127.0.0.1 port 25, so a MTA is required to send any email.<br>
	Requires tcllib packages mime and base64.
	[doc_list email_send]
    }
}

proc qc::email_send {args} {
    set argnames [args2vars $args]
    # email_send from to subject text|html ?cc? ?bcc? ?reply-to? ?attachment? ?attachments? ?filename? ?filenames?

    #| attachments is a list of dicts
    #| dict keys are encoding data filename ?cid?
    #| Example dict - {encoding base64 data aGVsbG8= cid 1312967973006309 filename attach1.pdf}
    #| Including cid in this dict is optional, if provided it must be world-unique
    #| cid can be used to reference an attachment within the email's html.
    #| eg. embed an image (<img src="cid:1312967973006309"/>).

    # From
    set mail_from [qc::email_address $from]
    lappend headers From $from
    # To
    set rcpt [list]
    foreach address [qc::email_addresses $to] {
	lappend rcpts $address
    }
    lappend headers To $to
    # CC
    if { [info exists cc] } {
	foreach address [qc::email_addresses $cc] {
	    lappend rcpts $address
	}
	lappend headers CC $cc
    }
    # BCC
    if { [info exists bcc] } {
	foreach address [qc::email_addresses $bcc] {
	    lappend rcpts $address
	}
    }
    # Subject
    lappend headers Subject $subject
    # Reply-To
    if { [info exists reply-to] } {
	lappend headers Reply-To ${reply-to}
    }
    # Date
    lappend headers Date [ns_httptime [ns_time]] 
    # MIME
    lappend headers MIME-Version 1.0
    # Message-ID
    #lappend headers Message-ID "<[::uuid::uuid generate]>"

    default attachments [list]
    # Single attachment
    if { [info exists attachment] } {
	lappend attachments $attachment
    }
    # Single file 
    if { [info exists filename] } {
	set filenames [list $filename]
    }
    # Attachments from filenames
    if { [info exists filenames] } {
	foreach filename $filenames {
	    lappend attachments [qc::email_file2attachment $filename]
	}
    }
    if { [info exists attachments] } {
	if { [ldict_exists $attachments cid] != -1 } {
	    # if any attachment specifies a Content-ID via key cid then type is related
	    set {content-type} multipart/related
	} else {
	    set {content-type} multipart/mixed
	}
	
	set boundary [format "%x" [clock seconds]][format "%x" [clock clicks]]
	lappend headers Content-Type "${content-type}; boundary=\"$boundary\""
	if { [info exists html] } {
	    # HTML and text subpart
	    set boundary2 [format "%x" [clock seconds]][format "%x" [clock clicks]]
	    set body2 [qc::email_mime_html_alternative $html $boundary2]
	    lappend parts [list headers [list Content-Type "multipart/alternative; boundary=\"$boundary2\""] body $body2]
	} else {
	    # Text Only
	    lappend parts [qc::email_mime_text $text]
	}
	# add attachments
	foreach dict $attachments {
	    lappend parts [qc::email_mime_attachment $dict]
	}
	set body [qc::email_mime_join $parts $boundary]
    } else {
	if { [info exists html] } {
	    # HTML with text alternative
	    set boundary [format "%x" [clock seconds]][format "%x" [clock clicks]]
	    lappend headers Content-Type "multipart/alternative; boundary=\"$boundary\""
	    set body [qc::email_mime_html_alternative $html $boundary]
	} else {
	    # Text Only
	    lappend headers Content-Transfer-Encoding quoted-printable Content-Type "text/plain; charset=utf-8"
	    set body $text
	}
    }  
    qc::sendmail $mail_from $rcpts $body {*}$headers
}

proc qc::email_file2attachment {filename} {
    set fhandle [open $filename r]
    fconfigure $fhandle -buffering line -translation binary -blocking 1
    set base64 [::base64::encode [read $fhandle]]
    set filename [file tail $filename]
    return [list encoding base64 data $base64 filename $filename]
}

proc qc::email_address {text} {
    return [lindex [qc::email_addresses $text] 0]
}

proc qc::email_addresses {text} {
    set list [list]
    foreach dict [mime::parseaddress $text] {
	lappend list [dict get $dict address]
    }
    return $list
}

proc qc::email_mime_text {text} {
    set headers [list]
    lappend headers Content-Transfer-Encoding quoted-printable Content-Type "text/plain; charset=utf-8"
    return [list headers $headers body [::mime::qp_encode $text]]
}

proc qc::email_mime_html_alternative {html boundary} {
    # Text
    set text [html2text $html]
    lappend parts [list headers [list Content-Type "text/plain;charset=\"utf-8\"" Content-Transfer-Encoding quoted-printable] body [::mime::qp_encode $text]]
    lappend parts [list headers [list Content-Type "text/html;charset=\"utf-8\"" Content-Transfer-Encoding quoted-printable] body [::mime::qp_encode $html]]
    return [qc::email_mime_join $parts $boundary]
}

proc qc::email_mime_attachment {dict} {
    # dict keys: data filename ?encoding? ?cid?
    dict2vars $dict encoding data cid filename
    set headers [list]
    set mimetype [ns_guesstype [file tail $filename]]
 
    if { ![info exists encoding] } {
	# No encoding provided so assume binary data even if text
	set encoding base64
	set data [::base64::encode $data]
    }
    lappend headers Content-Type "$mimetype;name=\"$filename\""
    lappend headers Content-Transfer-Encoding $encoding
    if { [info exists cid] } {
	lappend headers Content-ID <$cid>
    } else {
	lappend headers Content-Disposition "attachment;filename=\"$filename\""
    }

    return [list headers $headers body $data]
}

proc qc::email_mime_join {parts boundary} {
    lappend list "--${boundary}"
    foreach part $parts {
	lappend list [qc::email_mime_part $part]
	lappend list "--${boundary}"
    }
    lset list end "--${boundary}--"
    return [join $list \r\n]
}

proc qc::email_mime_part {part} {
    dict2vars $part headers body
    set list [list]
    foreach {name value} $headers {
	lappend list "$name: $value"
    }
    return [join $list \r\n]\r\n\r\n$body
}

proc qc::smtp_send {wfp string timeout} {
    #| Write data to the smtp server via wfp
    if {[lindex [ns_sockselect -timeout $timeout {} $wfp {}] 1] == ""} {
	error "Timeout writing to SMTP host"
    }
    puts -nonewline $wfp "$string\r\n"
    flush $wfp
}

proc qc::smtp_recv {rfp check timeout} {
    #| Read data from the smtp server via rfp
    while (1) {
	if {[lindex [ns_sockselect -timeout $timeout $rfp {} {}] 0] == ""} {
	    error "Timeout reading from SMTP host"
	}
	set line [gets $rfp]
	set code [string range $line 0 2]
	if ![string match $check $code] {
	    error "Expected a $check status line; got:\n$line"
	}
	if ![string match "-" [string range $line 3 3]] {
	    break;
	}
    }
}

proc qc::sendmail {mail_from rcpts body args} {
    #| Connect to the smtp host and send email message
    #| mail_from is a bare email address eg. root@localhost
    #| rcpts is a list of bare rcpt email addresses
    #| body is the plain text message usually in mime format.
    #| args is a name value pair list of mail headers  

    # Which SMTP server
    if { [ns_config ns/parameters smtphost] ne "" } {
	set smtphost [ns_config ns/parameters smtphost]
    } else {
	set smtphost localhost 
    }
    
    set smtpport 25
    set timeout 60
    set headers {}

    ## CONSTRUCT THE MESSAGE ##
    # Start with headers
    foreach {name value} $args {
	lappend headers [email_header_fold "$name: $value"]
    }
    set msg [join $headers \r\n]

    # Blank line between headers and body
    append msg \r\n\r\n

    # Add the body    
    # Convert all lines to \r\n
    regsub -all {([^\r])\n} $body "\\1\r\n" body
    regsub -all {\r([^\n])} $body "\r\n\\1" body

    # Escape lines starting with a dot .
    regsub -all {(^|\r\n)\.} $body "\\1.." body

    append msg $body

    # Termination
    append msg "\r\n."

    ## Open the connection ##
    set sock [ns_sockopen $smtphost $smtpport]
    set rfp [lindex $sock 0]
    set wfp [lindex $sock 1]

    ## Perform the SMTP conversation
    if { [catch {
	qc::smtp_recv $rfp 220 $timeout
	qc::smtp_send $wfp "HELO [ns_info hostname]" $timeout
	qc::smtp_recv $rfp 250 $timeout
	qc::smtp_send $wfp "MAIL FROM:<$mail_from>" $timeout
	qc::smtp_recv $rfp 250 $timeout
	
	foreach rcpt_to $rcpts {
	    qc::smtp_send $wfp "RCPT TO:<$rcpt_to>" $timeout
	    qc::smtp_recv $rfp 250 $timeout	
	}

	#qc::smtp_send $wfp "SIZE=[string bytelength $msg]" $timeout
	#qc::smtp_recv $rfp 250 $timeout

	qc::smtp_send $wfp DATA $timeout
	qc::smtp_recv $rfp 354 $timeout
	qc::smtp_send $wfp $msg $timeout
	qc::smtp_recv $rfp 250 $timeout
	qc::smtp_send $wfp QUIT $timeout
	qc::smtp_recv $rfp 221 $timeout
    } errMsg ] } {
	## Error, close and report
	close $rfp
	close $wfp
	return -code error $errMsg
    }

    ## Close the connection
    close $rfp
    close $wfp
}

doc sendmail {
    Parent email
    Examples {
	% 
	% sendmail $mail_from $rcpt_to $text Subject $subject Date [ns_httptime [ns_time]] MIME-Version 1.0 Content-Transfer-Encoding quoted-printable Content-Type "text/plain; charset=utf-8" From $from To $to
    }
}

proc qc::email2multimap {text} {
    # Convert an email message into a multimap data structure
    # Header values are mapped as key value pairs
    # If the message is multipart then the "bodies" key contains a list of the email parts
    # else the key "body" contains the message body
    #
    # A tree of multipart messages goes bodies->bodies->body

    set email {}
    regsub -all {\r\n} $text \n text
    lassign [split_pair $text "\n\n"] head body
    # remove line breaks from header values
    regsub -all {\n[ \t]+} $head { } head
    foreach line [split $head \n] {
	lassign [split_pair $line :] key value
	# Check if value is encoded
	lappend email $key $value
    }

    if { [multimap_exists $email Content-Type] } {
	set bodies {}
	array set header [email_header_values Content-Type [multimap_get_first $email Content-Type]]
	if { [string match multipart/* $header(Content-Type)] } {
	    foreach part [lrange [mcsplit $body "--$header(boundary)"] 1 end-1] {
		lappend bodies [qc::email2multimap [string trim $part]]
	    }
	    lappend email bodies $bodies
	} else {
	    # One part MIME
	    # Content-Transfer-Encoding
	    if { [multimap_exists $email Content-Transfer-Encoding] } {
		switch [multimap_get_first $email Content-Transfer-Encoding] {
		    7bit -
		    8bit -
		    binary {
		    }
		    quoted-printable {
			set body [::mime::qp_decode $body]
		    }
		    base64 {
			set body [::base64::decode_string $body]
		    }
		}
	    }
	    lappend email body $body
	}
    }
    return $email
}

proc email_header_values {key value} {
    # Convert
    # Content-Type: multipart/report; report-type=delivery-status; boundary="=_ventus"
    # to dict
    # $key multipart/report report-type delivery-status boundary =_ventus
    set dict {}
    set list [split $value ";"]
    lappend dict $key [lindex $list 0]
    foreach part [lrange $list 1 end] {
	lassign [split_pair $part =] key value
	lappend dict $key [string trim $value \"']
    }
    return $dict
}

proc email_header_fold {string} {
    # Fold header into lines starting with a space as per rfc2822
    set width 78

    # Convert to unix newlines for processing
    regsub -all {\r\n} $string \n string

    set start 0
    set list {}
    while { $start<[string length $string] && [regexp -indices -start $start -- {(\"[^\"]+\")|(\([^\)]+\))|([^ ]+)} $string match] } {
	set atom [string range $string [lindex $match 0] [lindex $match 1]]
	# If characters above 127 then encode
	if { [regexp {([\u007F-\u00FF])} $atom] } {
	    set list [concat $list [split [mime::word_encode utf-8 quoted-printable $atom] \n]]
	} else {
	    lappend list $atom
	}
	set start [expr {[lindex $match 1]+1}]
    }
    set result {}
    set line [lindex $list 0]
    foreach string [lrange $list 1 end] {
	if { [string length "$line $string"]<=78 } {
	    append line " $string"
	} else {
	    lappend result $line
	    set line $string
	}
    }
    lappend result $line
    return [string map {\n "\r\n "} [join $result \r\n]]
}

# Alternative approach to parsing email into mutimap adta structure

proc qc::email2multimap_ALT {source} {
    set dict {}
    set token [mime::initialize -string $source]
    set dict [qc::email_token2dict $token]
    foreach header [lintersect [mime::getheader $token -names] {From To Subject Date}] {
	lappend dict $header [lindex [mime::getheader $token $header] 0]
    }
    mime::finalize $token
    return $dict
}

proc qc::email_token2dict {token} {
    set dict {}
    set mime_type [mime::getproperty $token content]
    switch -glob -- $mime_type {
	multipart/* {
	    foreach part [mime::getproperty $token parts] {
		lappend dict $mime_type [qc::email_token2dict $part]
	    }
	}
	default {
	    lappend dict $mime_type [mime::getbody $token]
	}
    }
    return $dict
}