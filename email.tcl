package require mime
package require base64 

doc email {
    Title "Sending Email"
    Description {
	All of these procs call [doc_link sendmail] (which is based on ns_sendmail) and connects directly to an SMTP socket normally 127.0.0.1 port 25, so a MTA is required to send any email.<br>
	Requires tcllib packages mime and base64.
	[doc_list email_text email_html email_attachment email_attachment_text]
    }
}
	

proc qc::email_html { from to subject html args} {
    #| Send HTML email with alternative text copy
    #| Additional headers can be given through args.
    #| args is a name value pair list of mail headers  
    
    # headers
    if { [llength $args]==1 } {set args [lindex $args 0]}
    lappend args From $from To $to Subject $subject Date [ns_httptime [ns_time]] 
    set boundary [truncate [base64::encode [clock seconds][info hostname]] 70]
    lappend args MIME-Version 1.0 Content-Type "multipart/alternative; boundary=\"$boundary\""

    set text [html2text $html]
    set body {This is a multi-part message in MIME format.

--${boundary}
Content-Type: text/plain;charset="utf-8"
Content-Transfer-Encoding: quoted-printable


[::mime::qp_encode $text]
--${boundary}
Content-Type: text/html;charset="utf-8"
Content-Transfer-Encoding: quoted-printable


[::mime::qp_encode $html]
--${boundary}--
}
    qc::sendmail $from $to [subst $body] $args
}

doc email_html {
    Parent email
    Examples {
	email_html joe@from.com jill@to.com Hello "<b>Hello There</b>"
    }
}

proc qc::email_text { from to subject text } {
    #| Send a plain text email
    set text [::mime::qp_encode $text]
    qc::sendmail $from $to $text [list Subject $subject Date [ns_httptime [ns_time]] MIME-Version 1.0 Content-Transfer-Encoding quoted-printable Content-Type "text/plain; charset=utf-8" From $from To $to]
}

doc email_html {
    Parent email
    Examples {
	email_text joe@from.com jill@to.com Hello "Howdy There."
    }
}

proc qc::email_attachment_text { from to subject html text filename args} {
    #| Send HTML email with alternative text copy
    #| Attach a text file with given filename
  
    # headers
    if { [llength $args]==1 } {set args [lindex $args 0]}
    lappend args From $from To $to Subject $subject Date [ns_httptime [ns_time]] 
    set boundary1 "----=_NextPart1_[clock clicks]"
    set boundary2 "----=_NextPart2_[clock clicks]"
    lappend args MIME-Version 1.0 Content-Type "multipart/mixed; boundary=\"$boundary1\""

    set text_message [html2text $html]
    set body {This is a multi-part message in MIME format.

--${boundary1}
Content-Type: multipart/alternative; boundary="$boundary2"

This is a multi-part message in MIME format.

--${boundary2}
Content-Type: text/plain;charset="utf-8"
Content-Transfer-Encoding: quoted-printable

[::mime::qp_encode $text_message]

--${boundary2}
Content-Type: text/html;charset="utf-8"
Content-Transfer-Encoding: quoted-printable

[::mime::qp_encode $html]

--${boundary2}--

--${boundary1}
Content-Type: text/plain;name="$filename"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;filename="$filename"

[::mime::qp_encode $text]
--${boundary1}--
}
    qc::sendmail $from $to [subst $body] $args
}

doc email_attachment_text {
    Parent email
    Examples {
	email_attachment_text joe@from.com jill@to.com "Please find my <i>message</i> attached." "Hello There!"
    }
}

proc qc::email_attachment_base64 { from to subject html base64 mimetype filename} {
    #| Send HTML email with alternative text copy

    # headers
    set args {}
    lappend args From $from To $to Subject $subject Date [ns_httptime [ns_time]] 
    set boundary1 "----=_NextPart1_[clock clicks]"
    set boundary2 "----=_NextPart2_[clock clicks]"
    lappend args MIME-Version 1.0 Content-Type "multipart/mixed; boundary=\"$boundary1\""

    set text_message [html2text $html]

    set filename [file tail $filename]
    set mimetype [ns_guesstype $filename]
    
    set body {This is a multi-part message in MIME format.

--${boundary1}
Content-Type: multipart/alternative; boundary="$boundary2"

This is a multi-part message in MIME format.

--${boundary2}
Content-Type: text/plain;charset="utf-8"
Content-Transfer-Encoding: quoted-printable

[::mime::qp_encode $text_message]

--${boundary2}
Content-Type: text/html;charset="utf-8"
Content-Transfer-Encoding: quoted-printable

[::mime::qp_encode $html]

--${boundary2}--

--${boundary1}
Content-Type: $mimetype;name="$filename"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;filename="$filename"

$base64
--${boundary1}--
}
    qc::sendmail $from $to [subst $body] $args
}

proc qc::email_attachment { from to subject html filename args} {
    #| Send HTML email with alternative text copy
    #| Attach a file with given filename

    # headers
    if { [llength $args]==1 } {set args [lindex $args 0]}
    lappend args From $from To $to Subject $subject Date [ns_httptime [ns_time]] 
    set boundary1 "----=_NextPart1_[clock clicks]"
    set boundary2 "----=_NextPart2_[clock clicks]"
    lappend args MIME-Version 1.0 Content-Type "multipart/mixed; boundary=\"$boundary1\""

    set text_message [html2text $html]

    set fhandle [open $filename r]
    fconfigure $fhandle -buffering line -translation binary -blocking 1
    set attachment [base64::encode [read $fhandle]]

    set filename [file tail $filename]
    set mimetype [ns_guesstype $filename]
    
    set body {This is a multi-part message in MIME format.

--${boundary1}
Content-Type: multipart/alternative; boundary="$boundary2"

This is a multi-part message in MIME format.

--${boundary2}
Content-Type: text/plain;charset="utf-8"
Content-Transfer-Encoding: quoted-printable

[::mime::qp_encode $text_message]

--${boundary2}
Content-Type: text/html;charset="utf-8"
Content-Transfer-Encoding: quoted-printable

[::mime::qp_encode $html]

--${boundary2}--

--${boundary1}
Content-Type: $mimetype;name="$filename"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;filename="$filename"

$attachment
--${boundary1}--
}
    qc::sendmail $from $to [subst $body] $args
}

doc email_attachment {
    Parent email
    Examples {
	# Send a tar gzipped attachment by email using foo.tar.gz as the filename
	% email_attachment joe@from.com jill@to.com "Please find file <b>foo.tar.gz</b> attached." /tmp/foo.tar.gz
    }
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

proc qc::sendmail {mail_from rcpt_to body args} {
    #| Connect to the smtp host and send email message
    #| args is a name value pair list of mail headers  
    
    # Extract bare email address if needed
    # eg joe@blogs.com from "Joe Bloggs" <joe@bloggs.com>
    regexp {<([^>]*)>} $mail_from -> mail_from
    regexp {<([^>]*)>} $rcpt_to -> rcpt_to

    # Which SMTP server
    if { [ns_config ns/parameters smtphost] ne "" } {
	set smtphost [ns_config ns/parameters smtphost]
    } else {
	set smtphost localhost 
    }
    
    set smtpport 25
    set timeout 60
    set lheaders {}

    ## CONSTRUCT THE MESSAGE ##
    # Start with headers
    if { [llength $args]==1 } {set args [lindex $args 0]}
    foreach {name value} $args {
	lappend lheaders [email_header_fold "$name: $value"]
	#lappend lheaders "$name: $value"
    }
    set msg [join $lheaders \r\n]

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
	

	qc::smtp_send $wfp "RCPT TO:<$rcpt_to>" $timeout
	qc::smtp_recv $rfp 250 $timeout	
	
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

    set start 0
    set list {}
    while { $start<[string length $string] && [regexp -indices -start $start -- {(\"[^\"]+\")|(\([^\)]+\))|([^ ]+)} $string match] } {
	set atom [string range $string [lindex $match 0] [lindex $match 1]]
	# If characters above 127 then encode
	if { [regexp {([\u007F-\u00FF])} $atom] } {
	    set list [concat $list [split [mime::word_encode utf-8 quoted-printable $atom] \r\n]]
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

    return [string map {\r\n "\r\n "} [join $result \r\n]]
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