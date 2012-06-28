package provide qcode 1.6
package require doc
namespace eval qc {}
package require mime
package require base64 
package require uuid

doc email {
    Title "Sending Email"
    Description {
	All of these procs call <proc>sendmail</proc> (which is based on ns_sendmail) and connects directly to an SMTP socket normally 127.0.0.1 port 25, so a MTA is required to send any email.<br>
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
    set mimetype [qc::mime_type_guess [file tail $filename]]
 
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
			set body [::base64::decode_string $body]
		    }
		}
	    }
	    lappend email body $body
	}
    }
    return $email
}

proc qc::email_header_values {key value} {
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

proc qc::email_support { args } {
    #| Send email to support.
    # Masking any card numbers before sending.
    # Usage: email_support subject $subject ?html $html? ?text $text?

    args2vars $args
    set email_args [list from "nsd@[ns_info hostname]"]
    lappend email_args to [param email_support]
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
