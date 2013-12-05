package provide qcode 2.6.0
package require doc
namespace eval qc {
    namespace export email_* smtp_send smtp_recv sendmail email2multimap mime_type_guess qp_encode
}
package require mime
package require base64 
package require uuid

doc qc::email {
    Title "Sending Email"
    Url {/qc/wiki/SendingEmail}
}

proc qc::email_send {args} {
    set argnames [qc::args2vars $args]
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
    lappend headers Date [format_timestamp_http now] 
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

    # Split up mixed and related (cid that can be referenced in html) attachments 
    set mixed_attachments {}
    set related_attachments {}
    foreach attachment $attachments {
        if { [dict exists $attachment cid] } {
            lappend related_attachments $attachment
        } else {
            lappend mixed_attachments $attachment
        }
    }

    if { [info exists html] } {
        # HTML with text alternative
        set alternative_boundary [format "%x" [clock seconds]][format "%x" [clock clicks]]
        if { [string first "data:image/" $html]!=-1 } {
            # Embedded image data
            lassign [qc::email_html_embedded_images2attachments $html] html generated_attachments
            lappend related_attachments {*}$generated_attachments
        }
        set mime_body [qc::email_mime_html_alternative $html $alternative_boundary]
        set mime_headers [list Content-Type "multipart/alternative; boundary=\"$alternative_boundary\""]
    } else {
        # Text Only
        set mime_body [qc::qp_encode $text]
        set mime_headers [list Content-Transfer-Encoding quoted-printable Content-Type "text/plain; charset=utf-8"]
    }
    
    if { [llength $related_attachments] } {
        # Related attachments have a cid that can be referenced in email's html
        set related_boundary [format "%x" [clock seconds]][format "%x" [clock clicks]]
        set related_parts [list [list headers $mime_headers body $mime_body]]
        foreach attachment $related_attachments {
	    lappend related_parts [qc::email_mime_attachment $attachment]
	}

	set mime_body [qc::email_mime_join $related_parts $related_boundary]
        set mime_headers [list Content-Type "multipart/related; boundary=\"$related_boundary\""]
    }
    if { [llength $mixed_attachments] } {
        # Mixed attachments (standard attachments)
        set mixed_boundary [format "%x" [clock seconds]][format "%x" [clock clicks]]
        set mixed_parts [list [list headers $mime_headers body $mime_body]]
        foreach attachment $mixed_attachments {
	    lappend mixed_parts [qc::email_mime_attachment $attachment]
	}

	set mime_body [qc::email_mime_join $mixed_parts $mixed_boundary]
        set mime_headers [list Content-Type "multipart/mixed; boundary=\"$mixed_boundary\""]
    }

    lappend headers {*}$mime_headers
    qc::sendmail $mail_from $rcpts $mime_body {*}$headers
}

doc qc::email_send {
    Parent email
    Usage {email_send from to subject text|html ?cc? ?bcc? ?reply-to? ?attachment? ?attachments? ?filename? ?filenames?
	<br><em>arguments passed in as dict</em>}
    Description {Send email with plain text or html and add optional attachments}
    Examples {
	% qc::email_send from joe@bloggs.com to cool@fonzy.net subject Hi text "What's up"

	% qc::email_send from {"Tom Jones" <tommy@wales.com>} to "\"The Fonz\" <cool@fonzy.net>" \
	    cc "\"The King\" <elvis@graceland.org>" subject "Woah Woah" html "What's <i>new</i> pussy cat" 
	# If html2text is installed will provide a text alternative

	# Image attachment with base64 encoded data
	% qc::email_send from {"Tom Jones" <tommy@wales.com>} to {"The King" <elvis@graceland.org>} \
	    subject Hi text "The misses" \
	    attachment [list encoding base64 data "AsgHy...Jk==" filename Priscilla.png]

	#| attachments is a list of dicts
	#| dict keys are encoding data filename ?cid?
	#| Example dict - {encoding base64 data aGVsbG8= cid 1312967973006309 filename attach1.pdf}
	#| Including cid in this dict is optional, if provided it must be world-unique
	#| cid can be used to reference an attachment within the email's html.
	#| eg. embed an image (<img src="cid:1312967973006309"/>).
	
	# Image attachment used in html
	% qc::email_send from {"Tom Jones" <tommy@wales.com>} to {"The King" <elvis@graceland.org>} subject Hi \
	    html {<h2>Priscilla</h2><img src="cid:1312967973006309"/>} \
	    attachment [list encoding base64 data "AsgHy...Jk==" filename Priscilla.png cid 1312967973006309]
    }

}

proc qc::email_file2attachment {filename} {
    #| Return an attachment dict for this file
    set fhandle [open $filename r]
    fconfigure $fhandle -buffering line -translation binary -blocking 1
    set base64 [::base64::encode [read $fhandle]]
    close $fhandle
    set filename [file tail $filename]
    return [list encoding base64 data $base64 filename $filename]
}

proc qc::email_address {text} {
    #| Extract the email address from text
    return [lindex [qc::email_addresses $text] 0]
}

doc qc::email_address {
    Parent email
    Examples {
	% qc::email_address {"Joe Biden" <joe@biden.com>}
joe@biden.com
    }
}

proc qc::email_addresses {text} {
    #| Return a list of email addresses in the text
    set list [list]
    foreach dict [mime::parseaddress $text] {
	lappend list [dict get $dict address]
    }
    return $list
}

doc qc::email_addresses {
    Parent email
    Examples {
	% qc::email_addresses {"Joe Biden" <joe@biden.com> "Paul Ryan" <paul@ryan.com>}
	joe@biden.com paul@ryan.com
    }
}

proc qc::email_mime_html_alternative {html boundary} {
    #| Helper to return mime part for html part with plain text alternative
    set text [html2text $html]
    lappend parts [list headers [list Content-Type "text/plain;charset=\"utf-8\"" Content-Transfer-Encoding quoted-printable] body [qc::qp_encode $text]]
    lappend parts [list headers [list Content-Type "text/html;charset=\"utf-8\"" Content-Transfer-Encoding quoted-printable] body [qc::qp_encode $html]]
    return [qc::email_mime_join $parts $boundary]
}

proc qc::email_mime_attachment {dict} {
    #| Helper to return mime part for attachment
    # dict keys: data filename ?encoding? ?cid?
    dict2vars $dict encoding data cid filename
    set headers [list]
    set mimetype [qc::mime_type_guess [file tail $filename]]
 
    if { ![info exists encoding] } {
	# No encoding provided so assume binary data even if text
	set encoding base64
	set data [::base64::encode $data]
    }
    lappend headers Content-Type "$mimetype;name=\"$filename\""
    lappend headers Content-Transfer-Encoding $encoding
    if { [info exists cid] } {
        lappend headers Content-Disposition "inline;filename=\"$filename\""
	lappend headers Content-ID <$cid>
    } else {
	lappend headers Content-Disposition "attachment;filename=\"$filename\""
    }

    return [list headers $headers body $data]
}

proc qc::email_mime_join {parts boundary} {
    #| Helper to join mime parts
    lappend list "--${boundary}"
    foreach part $parts {
	lappend list [qc::email_mime_part $part]
	lappend list "--${boundary}"
    }
    lset list end "--${boundary}--"
    return [join $list \r\n]
}

proc qc::email_mime_part {part} {
    # Helper to construct mime part
    dict2vars $part headers body
    set list [list]
    foreach {name value} $headers {
	lappend list "$name: $value"
    }
    return [join $list \r\n]\r\n\r\n$body
}

proc qc::smtp_send {sock string timeout} {
    #| Write data to the smtp server via sock

    # All SMTP commands should be terminated by CRLF
    socket_puts -nonewline $sock "$string\r\n" $timeout
    flush $sock
}

proc qc::smtp_recv {sock check timeout} {
    #| Read data from the smtp server
    while (1) {
	set line [socket_gets $sock $timeout]
	set code [string range $line 0 2]
	if {$check ne $code} {
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

    set smtphost localhost
    
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
    set sock [socket_open $smtphost $smtpport $timeout]

    ## Perform the SMTP conversation
    if { [catch {
        qc::smtp_recv $sock 220 $timeout
        qc::smtp_send $sock "HELO [qc::my hostname]" $timeout
        qc::smtp_recv $sock 250 $timeout
        qc::smtp_send $sock "MAIL FROM:<$mail_from>" $timeout
        qc::smtp_recv $sock 250 $timeout
	
        foreach rcpt_to $rcpts {
            qc::smtp_send $sock "RCPT TO:<$rcpt_to>" $timeout
            qc::smtp_recv $sock 250 $timeout	
        }

        #qc::smtp_send $sock "SIZE=[string bytelength $msg]" $timeout
        #qc::smtp_recv $sock 250 $timeout
    
        qc::smtp_send $sock DATA $timeout
        qc::smtp_recv $sock 354 $timeout
        qc::smtp_send $sock $msg $timeout
        qc::smtp_recv $sock 250 $timeout
        qc::smtp_send $sock QUIT $timeout
        qc::smtp_recv $sock 221 $timeout
    } errMsg ] } {
        ## Error, close and report
        close $sock
        return -code error $errMsg
    }

    ## Close the connection
    close $sock
}

doc qc::sendmail {
    Parent email
    Examples {
	% 
	% sendmail $mail_from $rcpt_to $text Subject $subject Date [qc::format_timestamp_http now] MIME-Version 1.0 Content-Transfer-Encoding quoted-printable Content-Type "text/plain; charset=utf-8" From $from To $to
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
			set body [::base64::decode $body]
		    }
		}
	    }
	    lappend email body $body
	}
    }
    return $email
}

doc qc::email2multimap {
    Examples {
	% set email {
MIME-Version: 1.0
Received: by 10.216.2.9 with HTTP; Fri, 17 Aug 2012 04:51:36 -0700 (PDT)
Date: Fri, 17 Aug 2012 12:51:36 +0100
Delivered-To: bernhard@qcode.co.uk
Message-ID: <CAJF-9+0b5zv9TeOzm0jrnqPiMo4mfn1F5wkwcsbZ0Aj2Wjq1AA@mail.gmail.com>
Subject: Memo
From: Bernhard van Woerden <bernhard@qcode.co.uk>
To: Bernhard van Woerden <bernhard@qcode.co.uk>
Content-Type: multipart/mixed; boundary=0016e6d9a38e403c6904c774c888

--0016e6d9a38e403c6904c774c888
Content-Type: multipart/alternative; boundary=0016e6d9a38e403c6004c774c886

--0016e6d9a38e403c6004c774c886
Content-Type: text/plain; charset=ISO-8859-1

Please see the attached.

- Bernhard

--0016e6d9a38e403c6004c774c886
Content-Type: text/html; charset=ISO-8859-1

Please see the attached.<div><br></div><div>- Bernhard</div>

--0016e6d9a38e403c6004c774c886--
--0016e6d9a38e403c6904c774c888
Content-Type: text/plain; charset=US-ASCII; name="Memo.txt"
Content-Disposition: attachment; filename="Memo.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_h5z7vyc30

V291bGQgdGhlIGxhc3QgcGVyc29uIHRvIGxlYXZlIHBsZWFzZSB0dXJuIHRoZSBsaWdodHMgb2Zm
Lg==
--0016e6d9a38e403c6904c774c888--
}
    % qc::email2multimap $email
MIME-Version 1.0 Received {by 10.216.2.9 with HTTP; Fri, 17 Aug 2012 04:51:36 -0700 (PDT)} Date {Fri, 17 Aug 2012 12:51:36 +0100} Delivered-To bernhard@qcode.co.uk Message-ID <CAJF-9+0b5zv9TeOzm0jrnqPiMo4mfn1F5wkwcsbZ0Aj2Wjq1AA@mail.gmail.com> Subject Memo From {Bernhard van Woerden <bernhard@qcode.co.uk>} To {Bernhard van Woerden <bernhard@qcode.co.uk>} Content-Type {multipart/mixed; boundary=0016e6d9a38e403c6904c774c888} bodies {{Content-Type {multipart/alternative; boundary=0016e6d9a38e403c6004c774c886} bodies {{Content-Type {text/plain; charset=ISO-8859-1} body {Please see the attached.

- Bernhard}} {Content-Type {text/html; charset=ISO-8859-1} body {Please see the attached.<div><br></div><div>- Bernhard</div>}}}} {Content-Type {text/plain; charset=US-ASCII; name="Memo.txt"} Content-Disposition {attachment; filename="Memo.txt"} Content-Transfer-Encoding base64 X-Attachment-Id f_h5z7vyc30 body {Would the last person to leave please turn the lights off.}}}    
    }
}

proc qc::email_header_values {key value} {
    #| Convert header values to dict
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

proc qc::email_header_fold {string} {
    #| Fold header into lines starting with a space as per rfc2822
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

doc qc::email_header_fold {
    Examples {
	% qc::email_header_fold "This is a long line over the 78 characters allowed before folding at a word boundary where possible"
This is a long line over the 78 characters allowed before folding at a word
 boundary where possible
	% qc::email_header_fold "Non ASCII is treated like this pound sign £"
Non ASCII is treated like this pound sign =?UTF-8?Q?=C2=A3?=
    }
}

proc qc::email_token2dict {token} {
    # Helper to convert a mime token to dict
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

proc qc::email_support { args } {
    #| Send email to support.
    # Masking any card numbers before sending.
    # Usage: email_support subject $subject ?html $html? ?text $text?

    qc::args2vars $args subject html text
    if { [qc::param_exists hostname] } {
        set hostname [qc::param_get hostname]
    } else {
        set hostname [ns_info hostname]
    }
    set email_args [list from "nsd@$hostname"]
    lappend email_args to [qc::param_get email_support]
    lappend email_args subject [qc::format_cc_masked_string $subject]
    if { [info exists html] } {
	lappend email_args html [qc::format_cc_masked_string $html]
    } else {
	lappend email_args text [qc::format_cc_masked_string $text]
    }
    qc::email_send {*}$email_args
}

proc qc::mime_type_guess { filename } {
    #| Lookup a mimetype based on a file extension. Case insensitive.
    # Based on ns_guesstype.
    # Defaults to "*/*".
    
    set default_type "*/*"

    if { ![regexp {^\S+(\.[a-z]+)$} [qc::lower $filename] -> ext] } {
        return $default_type
    }
   
    switch $ext {
        ".adp"   -
        ".dci"   -
        ".htm"   -
        ".html"  -
        ".sht"   -
        ".shtml" {
            return "text/html"
        }
        ".ai" {
            return "application/postscript"
        }
        ".aif" {
            return "audio/aiff"
        }
        ".aifc" {
            return "audio/aiff"
        }
        ".aiff" {
            return "audio/aiff"
        }
        ".ani" {
            return "application/x-navi-animation"
        }
        ".art" {
            return "image/x-art"
        }
        ".asc" {
            return "text/plain"
        }
        ".au" {
            return "audio/basic"
        }
        ".avi" {
            return "video/x-msvideo"
        }
        ".bcpio" {
            return "application/x-bcpio"
        }
        ".bin" {
            return "application/octet-stream"
        }
        ".bmp" {
            return "image/bmp"
        }
        ".cdf" {
            return "application/x-netcdf"
        }
        ".cgm" {
            return "image/cgm"
        }
        ".class" {
            return "application/octet-stream"
        }
        ".cpio" {
            return "application/x-cpio"
        }
        ".cpt" {
            return "application/mac-compactpro"
        }
        ".css" {
            return "text/css"
        }
        ".csv" {
            return "application/csv"
        }
        ".dcr" {
            return "application/x-director"
        }
        ".der" {
            return "application/x-x509-ca-cert"
        }
        ".dir" {
            return "application/x-director"
        }
        ".dll" {
            return "application/octet-stream"
        }
        ".dms" {
            return "application/octet-stream"
        }
        ".doc" {
            return "application/msword"
        }
        ".dp" {
            return "application/commonground"
        }
        ".dvi" {
            return "applications/x-dvi"
        }
        ".dwg" {
            return "image/vnd.dwg"
        }
        ".dxf" {
            return "image/vnd.dxf"
        }
        ".dxr" {
            return "application/x-director"
        }
        ".elm" {
            return "text/plain"
        }
        ".eml" {
            return "text/plain"
        }
        ".etx" {
            return "text/x-setext"
        }
        ".exe" {
            return "application/octet-stream"
        }
        ".ez" {
            return "application/andrew-inset"
        }
        ".fm" {
            return "application/vnd.framemaker"
        }
        ".gbt" {
            return "text/plain"
        }    
        ".gif" {
            return "image/gif"
        }
        ".gtar" {
            return "application/x-gtar"
        }
        ".gz" {
            return "application/x-gzip"
        }
        ".hdf" {
            return "application/x-hdf"
        }
        ".hpgl" {
            return "application/vnd.hp-hpgl"
        }
        ".hqx" {
            return "application/mac-binhex40"
        }
        ".ice" {
            return "x-conference/x-cooltalk"
        }
        ".ief" {
            return "image/ief"
        }
        ".igs" {
            return "image/iges"
        }
        ".iges" {
            return "image/iges"
        }
        ".jfif" {
            return "image/jpeg"
        }
        ".jpe" {
            return "image/jpeg"
        }
        ".jpg" {
            return "image/jpeg"
        }
        ".jpeg" {
            return "image/jpeg"
        }
        ".js" {
            return "application/x-javascript"
        }
        ".kar" {
            return "audio/midi"
        }
        ".latex" {
            return "application/x-latex"
        }
        ".lha" {
            return "application/octet-stream"
        }
        ".ls" {
            return "application/x-javascript"
        }
        ".lxc" {
            return "application/vnd.ms-excel"
        }
        ".lzh" {
            return "application/octet-stream"
        }
        ".man" {
            return "application/x-troff-man"
        }
        ".map" {
            return "application/x-navimap"
        }
        ".me" {
            return "application/x-troff-me"
        }
        ".mesh" {
            return "model/mesh"
        }
        ".mid" {
            return "audio/x-midi"
        }
        ".midi" {
            return "audio/x-midi"
        }
        ".mif" {
            return "application/vnd.mif"
        }
        ".mocha" {
            return "application/x-javascript"
        }
        ".mov" {
            return "video/quicktime"
        }
        ".movie" {
            return "video/x-sgi-movie"
        }
        ".mp2" {
            return "audio/mpeg"
        }
        ".mp3" {
            return "audio/mpeg"
        }
        ".mpe" {
            return "video/mpeg"
        }
        ".mpeg" {
            return "video/mpeg"
        }
        ".mpg" {
            return "video/mpeg"
        }
        ".mpga" {
            return "audio/mpeg"
        }
        ".ms" {
            return "application/x-troff-ms"
        }
        ".msh" {
            return "model/mesh"
        }
        ".nc" {
            return "application/x-netcdf"
        }
        ".nvd" {
            return "application/x-navidoc"
        }
        ".nvm" {
            return "application/x-navimap"
        }
        ".oda" {
            return "application/oda"
        }
        ".pbm" {
            return "image/x-portable-bitmap"
        }
        ".pcl" {
            return "application/vnd.hp-pcl"
        }
        ".pclx" {
            return "application/vnd.hp-pclx"
        }
        ".pdb" {
            return "chemical/x-pdb"
        }
        ".pdf" {
            return "application/pdf"
        }
        ".pgm" {
            return "image/x-portable-graymap"
        }
        ".pgn" {
            return "application/x-chess-pgn"
        }
        ".pic" {
            return "image/pict"
        }
        ".pict" {
            return "image/pict"
        }
        ".pnm" {
            return "image/x-portable-anymap"
        }
        ".png" {
            return "image/png"
        }
        ".pot" {
            return "application/vnd.ms-powerpoint"
        }
        ".ppm" {
            return "image/x-portable-pixmap"
        }
        ".pps" {
            return "application/vnd.ms-powerpoint"
        }
        ".ppt" {
            return "application/vnd.ms-powerpoint"
        }
        ".ps" {
            return "application/postscript"
        }
        ".qt" {
            return "video/quicktime"
        }
        ".ra" {
            return "audio/x-realaudio"
        }
        ".ram" {
            return "audio/x-pn-realaudio"
        }
        ".ras" {
            return "image/x-cmu-raster"
        }
        ".rgb" {
            return "image/x-rgb"
        }
        ".rm" {
            return "audio/x-pn-realaudio"
        }
        ".roff" {
            return "application/x-troff"
        }
        ".rpm" {
            return "audio/x-pn-realaudio-plugin"
        }
        ".rtf" {
            return "application/rtf"
        }
        ".rtx" {
            return "text/richtext"
        }
        ".sda" {
            return "application/vnd.stardivision.draw"
        }
        ".sdc" {
            return "application/vnd.stardivision.calc"
        }
        ".sdd" {
            return "application/vnd.stardivision.impress"
        }
        ".sdp" {
            return "application/vnd.stardivision.impress"
        }
        ".sdw" {
            return "application/vnd.stardivision.writer"
        }
        ".sgl" {
            return "application/vnd.stardivision.writer-global"
        }
        ".sgm" {
            return "text/sgml"
        }
        ".sgml" {
            return "text/sgml"
        }
        ".sh" {
            return "application/x-sh"
        }
        ".shar" {
            return "application/x-shar"
        }
        ".silo" {
            return "model/mesh"
        }
        ".sit" {
            return "application/x-stuffit"
        }
        ".skd" {
            return "application/vnd.stardivision.math"
        }
        ".skm" {
            return "application/vnd.stardivision.math"
        }
        ".skp" {
            return "application/vnd.stardivision.math"
        }
        ".skt" {
            return "application/vnd.stardivision.math"
        }
        ".smf" {
            return "application/vnd.stardivision.math"
        }
        ".smi" {
            return "application/smil"
        }
        ".smil" {
            return "application/smil"
        }
        ".snd" {
            return "audio/basic"
        }
        ".spl" {
            return "application/x-futuresplash"
        }
        ".sql" {
            return "application/x-sql"
        }
        ".src" {
            return "application/x-wais-source"
        }
        ".stc" {
            return "application/vnd.sun.xml.calc.template"
        }
        ".std" {
            return "application/vnd.sun.xml.draw.template"
        }
        ".sti" {
            return "application/vnd.sun.xml.impress.template"
        }
        ".stl" {
            return "application/x-navistyle"
        }
        ".stw" {
            return "application/vnd.sun.xml.writer.template"
        }
        ".swf" {
            return "application/x-shockwave-flash"
        }
        ".sxc" {
            return "application/vnd.sun.xml.calc"
        }
        ".sxd" {
            return "application/vnd.sun.xml.draw"
        }
        ".sxg" {
            return "application/vnd.sun.xml.writer.global"
        }
        ".sxl" {
            return "application/vnd.sun.xml.impress"
        }
        ".sxm" {
            return "application/vnd.sun.xml.math"
        }
        ".sxw" {
            return "application/vnd.sun.xml.writer"
        }
        ".t" {
            return "application/x-troff"
        }
        ".tar" {
            return "application/x-tar"
        }
        ".tcl" {
            return "x-tcl"
        }
        ".tex" {
            return "application/x-tex"
        }
        ".texi" {
            return "application/x-texinfo"
        }
        ".texinfo" {
            return "application/x-texinfo"
        }
        ".text" {
            return "text/plain"
        }
        ".tgz" {
            return "application/x-gtar"
        }
        ".tif" {
            return "image/tiff"
        }
        ".tiff" {
            return "image/tiff"
        }
        ".tr" {
            return "application/x-troff"
        }
        ".tsv" {
            return "text/tab-separated-values"
        }
        ".txt" {
            return "text/plain"
        }
        ".ustar" {
            return "application/x-ustar"
        }
        ".vcd" {
            return "application/x-cdlink"
        }
        ".vor" {
            return "application/vnd.stardivision.writer"
        }
        ".vrml" {
            return "model/vrml"
        }
        ".wav" {
            return "audio/x-wav"
        }
        ".wbmp" {
            return "image/vnd.wap.wbmp"
        }
        ".wkb" {
            return "application/vnd.ms-excel"
        }
        ".wks" {
            return "application/vnd.ms-excel"
        }
        ".wml" {
            return "text/vnd.wap.wml"
        }
        ".wmlc" {
            return "application/vnd.wap.wmlc"
        }
        ".wmls" {
            return "text/vnd.wap.wmlscript"
        }
        ".wmlsc" {
            return "application/vnd.wap.wmlscript"
        }
        ".wrl" {
            return "model/vrml"
        }
        ".xbm" {
            return "image/x-xbitmap"
        }
        ".xls" {
            return "application/vnd.ms-excel"
        }
        ".xlw" {
            return "application/vnd.ms-excel"
        }
        ".xpm" {
            return "image/x-xpixmap"
        }
        ".xht" {
            return "application/xhtml+xml"
        }
        ".xhtml" {
            return "application/xhtml+xml"
        }
        ".xml" {
            return "text/xml"
        }
        ".xsl" {
            return "text/xml"
        }
        ".xyz" {
            return "chemical/x-pdb"
        }
        ".xwd" {
            return "image/x-xwindowdump"
        }
        ".z" {
            return "application/x-compress"
        }
        ".zip" {
            return "application/zip"
        }
        default {
            return $default_type
        }
    }
}

doc qc::mime_type_guess {
    Examples {
	% qc::mime_type_guess foo.pdf
	application/pdf
	% qc::mime_type_guess crack.exe
	application/octet-stream
    }
}

proc qc::qp_encode {string {encoded_word 0} {no_softbreak 0}} {
    # Based on ::mime::qp_encode, but uses \r\n instead of only \n

    regsub -all -- \
	    {[\x00-\x08\x0B-\x1E\x21-\x24\x3D\x40\x5B-\x5E\x60\x7B-\xFF]} \
	    $string {[format =%02X [scan "\\&" %c]]} string

    # Replace the format commands with their result

    set string [subst -novariable $string]

    # soft/hard newlines and other
    # Funky cases for SMTP compatibility
    set mapChars [list " \n" "=20\n" "\t\n" "=09\n" \
	    "\n\.\n" "\n=2E\n" "\nFrom " "\n=46rom "]
    if {$encoded_word} {
	# Special processing for encoded words (RFC 2047)
	lappend mapChars " " "_"
    }
    set string [string map $mapChars $string]

    # Break long lines - ugh

    # Implementation of FR #503336
    if {$no_softbreak} {
	set result $string
    } else {
	set result ""
	foreach line [split $string \n] {
	    while {[string length $line] > 72} {
		set chunk [string range $line 0 72]
		if {[regexp -- (=|=.)$ $chunk dummy end]} {

		    # Don't break in the middle of a code

		    set len [expr {72 - [string length $end]}]
		    set chunk [string range $line 0 $len]
		    incr len
		    set line [string range $line $len end]
		} else {
		    set line [string range $line 73 end]
		}
		append result $chunk=\r\n
	    }
	    append result $line\r\n
	}
    
	# Trim off last \r\n, since the above code has the side-effect
	# of adding an extra \r\n to the encoded string and return the
	# result.
	set result [string range $result 0 end-2]
    }

    # If the string ends in space or tab, replace with =xx

    set lastChar [string index $result end]
    if {$lastChar==" "} {
	set result [string replace $result end end "=20"]
    } elseif {$lastChar=="\t"} {
	set result [string replace $result end end "=09"]
    }

    return $result
}

proc qc::email_html_embedded_images2attachments {html} {
    #| Converts embedded images in the given html string to attachments
    # Returns the html with image src cids, and an ldict of attachments
    set attachments {}
    dom parse -html $html doc
    set nodes [$doc selectNodes "//img\[starts-with(@src,'data:image/')\]"]
    
    foreach node $nodes {
        set src [$node getAttribute src]
        regexp {^data:image/([a-z]+);base64,(.*)$} $src -> file_type base64
        set filename [uuid::uuid generate].${file_type}
        set cid ${filename}@[clock seconds]
        lappend attachments [dict create encoding base64 data $base64 filename $filename cid $cid]
        $node setAttribute src "cid:${cid}"
    }
    set html [$doc asHTML]
    $doc delete
    return [list $html $attachments]
}
