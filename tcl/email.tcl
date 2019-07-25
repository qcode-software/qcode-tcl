namespace eval qc {
    namespace export email_* smtp_send smtp_recv sendmail email2multimap mime_type_guess qp_encode
}
package require mime
package require base64 
package require uuid

proc qc::email_send {args} {
    set argnames [qc::args2vars $args]
    # email_send from to subject text|html ?cc? ?bcc? ?reply-to? ?bounce-to? ?sender? ?attachment? ?attachments? ?filename? ?filenames?

    #| attachments is a list of dicts
    #| dict keys are encoding data filename ?cid?
    #| Example dict - {encoding base64 data aGVsbG8= cid 1312967973006309 filename attach1.pdf}
    #| Including cid in this dict is optional, if provided it must be world-unique
    #| cid can be used to reference an attachment within the email's html.
    #| eg. embed an image (<img src="cid:1312967973006309"/>).

    # Return-Path
    # The MTA will set the Return-Path based on the $mail_from value
    if { [info exists bounce-to] } {
        set mail_from [qc::email_address ${bounce-to}]
    } elseif { [info exists sender] } {
        set mail_from [qc::email_address $sender]
    } else {
        set mail_from [qc::email_address $from]
    }

    # Sender
    if { [info exists sender] } {
        lappend headers Sender $sender
    }

    # From
    lappend headers From $from
    # To
    set rcpts [list]
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
        set alternative_boundary [uuid::uuid generate]
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
        set related_boundary [uuid::uuid generate]
        set related_parts [list [list headers $mime_headers body $mime_body]]
        foreach attachment $related_attachments {
	    lappend related_parts [qc::email_mime_attachment $attachment]
	}

	set mime_body [qc::email_mime_join $related_parts $related_boundary]
        set mime_headers [list Content-Type "multipart/related; boundary=\"$related_boundary\""]
    }
    if { [llength $mixed_attachments] } {
        # Mixed attachments (standard attachments)
        set mixed_boundary [uuid::uuid generate]
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

proc qc::email_addresses {text} {
    #| Return a list of email addresses in the text
    set list [list]
    foreach dict [mime::parseaddress $text] {
	lappend list [dict get $dict address]
    }
    return $list
}

proc qc::email_mime_html_alternative {html boundary} {
    #| Helper to return mime part for html part with plain text alternative
    set text [html2text $html]
    lappend parts [list headers [list Content-Type "text/plain;charset=\"utf-8\"" Content-Transfer-Encoding quoted-printable] body [qc::qp_encode [encoding convertto utf-8 $text]]]
    lappend parts [list headers [list Content-Type "text/html;charset=\"utf-8\"" Content-Transfer-Encoding quoted-printable] body [qc::qp_encode [encoding convertto utf-8 $html]]]
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
	lappend email $key [qc::email_header_value_decode $value]
    }
    
    if { [multimap_exists $email Content-Type] } {
        # MIME message
	set bodies {}
	array set header [email_header_values Content-Type [multimap_get_first $email Content-Type]]
	if { [string match multipart/* $header(Content-Type)] } {
            # Multi-part MIME
	    foreach part [lrange [mcsplit $body "--$header(boundary)"] 1 end-1] {
                lappend bodies [qc::email2multimap $part]
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
                        if { [info exists header(charset)] } {
                            set encoding [IANAEncoding2TclEncoding $header(charset)]
                            set body [encoding convertfrom $encoding $body]
                        } 
		    }
		    base64 {
			set body [::base64::decode $body]
                        if { [info exists header(charset)] } {
                            set encoding [IANAEncoding2TclEncoding $header(charset)]
                            set body [encoding convertfrom $encoding $body]
                        } 
		    }
		}
            }
	    lappend email body $body
	}
    } else {
        # Non-MIME message
        lappend email body $body
    }
    return $email
}

proc qc::email_header_value_decode {value} {
    #| Decode an encoded header value as per rfc-2047
    # eg. =?UTF-8?B?UWNvZGUgUm9ja3M=?=
    if { [regexp {^=\?[^ \?]+\?[QBqb]\?[^ ]+?=$} $value] } {
        lassign [mime::word_decode $value] charset method string
        return [encoding convertfrom $charset $string]
    } else {
        return $value
    }
}

proc qc::email_header_values {key value} {
    #| Convert header values to dict
    # Convert
    # Content-Type: multipart/report; report-type=delivery-status; boundary="=_ventus"
    # to dict
    # $key {Content-Type: multipart/report} report-type delivery-status boundary =_ventus
    # lower case parameter attribute names to allow case insensitive matching
    set dict {}
    set remainder [string trimright $value ";"]

    # Get first value
    set index [string first ";" $value]    
    if { $index == -1 } {
        dict set dict $key $remainder
        return $dict
    }
    dict set dict $key [string range $remainder 0 ${index}-1]
    set remainder [string range $remainder ${index}+1 end]
    set remainder [string trimleft $remainder]

    # Loop until entire string is parsed, limit to string length as sanity check
    foreach saftey [.. 0 [string length $remainder]] {

        # Remove key from start of remainder
        set index [string first "=" $remainder]
        if { $index == -1 } {
            error "Missing value for key \"$remainder\""
        }
        set key [string range $remainder 0 ${index}-1]
        set remainder [string range $remainder ${index}+1 end]

        set remainder [string trimleft $remainder]

        # Remove value from start of remainder
        set first_char [string index $remainder 0]
        switch $first_char {
            ' -
            \" {
                # Value begins with quote, search for next matching quote
                # (excluding escaped quotes)
                set index 0
                foreach saftey2 [.. 0 [string length $remainder]] {
                    set index [string first $first_char $remainder ${index}+1]
                    if { $index == -1 } {
                        error "Unbalanced quotes in \"$remainder\""
                    }
                    set preceding_backslashes 0
                    foreach index2 [.. $index 1 -1] {
                        if { [string index $remainder ${index2}-1] eq "\\" } {
                            incr preceding_backslashes
                        } else {
                            break
                        }
                    }
                    if { $preceding_backslashes % 2 == 0 } {
                        break
                    }
                }
                set value [string range $remainder 1 ${index}-1]

                # Un-escape escaped characters
                set value [regsub -all {\\(.)} $value {\1}]
                
                set remainder [string range $remainder ${index}+1 end]
                
                set remainder [string trimleft $remainder]

                if { [string length $remainder] > 0
                     &&
                     [string index $remainder 0] ne ";"
                 } {
                    error "Invalid characters after close-quote ($remainder)"
                }

                set remainder [string range $remainder 1 end]
            }
            default {
                # Value is all remaining string up to the first ;
                set index [string first ";" $remainder]
                if { $index == -1 } {
                    set value $remainder
                    set remainder ""
                } else {
                    set value [string range $remainder 0 ${index}-1]
                    set remainder [string range $remainder ${index}+1 end]
                }
            }
        }
        set remainder [string trimleft $remainder]
        
        set value [qc::email_header_value_decode $value]
	lappend dict [string tolower $key] $value
        if { $remainder eq "" } {
            break
        }
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

    set ext [file extension [string tolower $filename]]
    if { $ext eq "" } {
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
        ".docx" {
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
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
        ".svg" {
            return "image/svg+xml"
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
        ".xlsx" {
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
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

proc qc::mime_file_extension { mime_type } {
    #| Lookup a file extension based on mime_type
    set map {
        "text/plain" ".txt"
        "text/html" ".html"
        "application/postscript" ".ai"
        "audio/aiff" ".aif"
        "audio/aiff" ".aifc"
        "audio/aiff" ".aiff"
        "application/x-navi-animation" ".ani"
        "image/x-art" ".art"
        "audio/basic" ".au"
        "video/x-msvideo" ".avi"
        "application/x-bcpio" ".bcpio"
        "application/octet-stream" ".bin"
        "image/bmp" ".bmp"
        "application/x-netcdf" ".cdf"
        "image/cgm" ".cgm"
        "application/octet-stream" ".class"
        "application/x-cpio" ".cpio"
        "application/mac-compactpro" ".cpt"
        "text/css" ".css"
        "application/csv" ".csv"
        "application/x-director" ".dcr"
        "application/x-x509-ca-cert" ".der"
        "application/x-director" ".dir"
        "application/octet-stream" ".dll"
        "application/octet-stream" ".dms"
        "application/msword" ".doc"
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ".docx"
        "application/commonground" ".dp"
        "applications/x-dvi" ".dvi"
        "image/vnd.dwg" ".dwg"
        "image/vnd.dxf" ".dxf"
        "application/x-director" ".dxr"
        "text/x-setext" ".etx"
        "application/octet-stream" ".exe"
        "application/andrew-inset" ".ez"
        "application/vnd.framemaker" ".fm"
        "image/gif" ".gif"
        "application/x-gtar" ".gtar"
        "application/x-gzip" ".gz"
        "application/x-hdf" ".hdf"
        "application/vnd.hp-hpgl" ".hpgl"
        "application/mac-binhex40" ".hqx"
        "x-conference/x-cooltalk" ".ice"
        "image/ief" ".ief"
        "image/iges" ".igs"
        "image/iges" ".iges"
        "image/jpeg" ".jpg"
        "application/x-javascript" ".js"
        "audio/midi" ".kar"
        "application/x-latex" ".latex"
        "application/octet-stream" ".lha"
        "application/x-javascript" ".ls"
        "application/vnd.ms-excel" ".lxc"
        "application/octet-stream" ".lzh"
        "application/x-troff-man" ".man"
        "application/x-navimap" ".map"
        "application/x-troff-me" ".me"
        "model/mesh" ".mesh"
        "audio/x-midi" ".mid"
        "audio/x-midi" ".midi"
        "application/vnd.mif" ".mif"
        "application/x-javascript" ".mocha"
        "video/quicktime" ".mov"
        "video/x-sgi-movie" ".movie"
        "audio/mpeg" ".mp2"
        "audio/mpeg" ".mp3"
        "video/mpeg" ".mpe"
        "video/mpeg" ".mpeg"
        "video/mpeg" ".mpg"
        "audio/mpeg" ".mpga"
        "application/x-troff-ms" ".ms"
        "model/mesh" ".msh"
        "application/x-netcdf" ".nc"
        "application/x-navidoc" ".nvd"
        "application/x-navimap" ".nvm"
        "application/oda" ".oda"
        "image/x-portable-bitmap" ".pbm"
        "application/vnd.hp-pcl" ".pcl"
        "application/vnd.hp-pclx" ".pclx"
        "chemical/x-pdb" ".pdb"
        "application/pdf" ".pdf"
        "image/x-portable-graymap" ".pgm"
        "application/x-chess-pgn" ".pgn"
        "image/pict" ".pic"
        "image/pict" ".pict"
        "image/x-portable-anymap" ".pnm"
        "image/png" ".png"
        "application/vnd.ms-powerpoint" ".pot"
        "image/x-portable-pixmap" ".ppm"
        "application/vnd.ms-powerpoint" ".pps"
        "application/vnd.ms-powerpoint" ".ppt"
        "application/postscript" ".ps"
        "video/quicktime" ".qt"
        "audio/x-realaudio" ".ra"
        "audio/x-pn-realaudio" ".ram"
        "image/x-cmu-raster" ".ras"
        "image/x-rgb" ".rgb"
        "audio/x-pn-realaudio" ".rm"
        "application/x-troff" ".roff"
        "audio/x-pn-realaudio-plugin" ".rpm"
        "application/rtf" ".rtf"
        "text/richtext" ".rtx"
        "application/vnd.stardivision.draw" ".sda"
        "application/vnd.stardivision.calc" ".sdc"
        "application/vnd.stardivision.impress" ".sdd"
        "application/vnd.stardivision.impress" ".sdp"
        "application/vnd.stardivision.writer" ".sdw"
        "application/vnd.stardivision.writer-global" ".sgl"
        "text/sgml" ".sgml"
        "application/x-sh" ".sh"
        "application/x-shar" ".shar"
        "model/mesh" ".silo"
        "application/x-stuffit" ".sit"
        "application/vnd.stardivision.math" ".skd"
        "application/vnd.stardivision.math" ".skm"
        "application/vnd.stardivision.math" ".skp"
        "application/vnd.stardivision.math" ".skt"
        "application/vnd.stardivision.math" ".smf"
        "application/smil" ".smi"
        "application/smil" ".smil"
        "audio/basic" ".snd"
        "application/x-futuresplash" ".spl"
        "application/x-sql" ".sql"
        "application/x-wais-source" ".src"
        "application/vnd.sun.xml.calc.template" ".stc"
        "application/vnd.sun.xml.draw.template" ".std"
        "application/vnd.sun.xml.impress.template" ".sti"
        "application/x-navistyle" ".stl"
        "application/vnd.sun.xml.writer.template" ".stw"
        "image/svg+xml" ".svg"
        "application/x-shockwave-flash" ".swf"
        "application/vnd.sun.xml.calc" ".sxc"
        "application/vnd.sun.xml.draw" ".sxd"
        "application/vnd.sun.xml.writer.global" ".sxg"
        "application/vnd.sun.xml.impress" ".sxl"
        "application/vnd.sun.xml.math" ".sxm"
        "application/vnd.sun.xml.writer" ".sxw"
        "application/x-troff" ".t"
        "application/x-tar" ".tar"
        "x-tcl" ".tcl"
        "application/x-tex" ".tex"
        "application/x-texinfo" ".texi"
        "application/x-texinfo" ".texinfo"
        "application/x-gtar" ".tgz"
        "image/tiff" ".tif"
        "application/x-troff" ".tr"
        "text/tab-separated-values" ".tsv"
        "application/x-ustar" ".ustar"
        "application/x-cdlink" ".vcd"
        "application/vnd.stardivision.writer" ".vor"
        "model/vrml" ".vrml"
        "audio/x-wav" ".wav"
        "image/vnd.wap.wbmp" ".wbmp"
        "application/vnd.ms-excel" ".wkb"
        "application/vnd.ms-excel" ".wks"
        "text/vnd.wap.wml" ".wml"
        "application/vnd.wap.wmlc" ".wmlc"
        "text/vnd.wap.wmlscript" ".wmls"
        "application/vnd.wap.wmlscript" ".wmlsc"
        "model/vrml" ".wrl"
        "image/x-xbitmap" ".xbm"
        "application/vnd.ms-excel" ".xls"
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" ".xlsx"
        "application/vnd.ms-excel" ".xlw"
        "image/x-xpixmap" ".xpm"
        "application/xhtml+xml" ".xht"
        "application/xhtml+xml" ".xhtml"
        "text/xml" ".xml"
        "text/xml" ".xsl"
        "chemical/x-pdb" ".xyz"
        "image/x-xwindowdump" ".xwd"
        "application/x-compress" ".z"
        "application/zip" ".zip"
    }
    if { [dict exists $map $mime_type] } {
        return [dict get $map $mime_type]
    } else {
        error "No file extension defined for mime type \"$mime_type\""
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
