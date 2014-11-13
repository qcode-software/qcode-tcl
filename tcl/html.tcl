namespace eval qc {
    namespace export html2* html html_tag html_escape html_unescape html_hidden html_hidden_set html_list html_a html_a_replace html_id html_menu html_paragraph_layout html_info_tables html_styles2inline html_style2inline html_col_styles_apply2td html_clean strip_html
}

proc qc::html2pdf { args } {
    # | Looks for wkhtmltopdf binary to generate PDF.
    # | If not found, use the URL specified by param pdfserver.
    # | Currently v0.9.9 of wkhtmltopdf is supported.
    # usage html2pdf ?-encoding encoding? ?-timeout timeout(secs)? html
    args $args -encoding base64 -timeout 20 html
    if { ![in {base64 binary} $encoding] } {
        error "HTML2PDF: Unknown encoding $encoding"
    }
  
    if { ! [file exists /usr/local/bin/wkhtmltopdf] } {
        # No binary found, send job to html2pdf server
        set url [qc::param_get pdfserver]
        set pdf [qc::http_post -timeout $timeout -content-type "text/plain; charset=utf-8" -accept "text/plain; charset=utf-8" $url htmlblock $html outputencoding $encoding]
        return $pdf
    } else {
        # The binary is present so use it.
        set wkhtmltopdf [qc::which wkhtmltopdf]
        package require fileutil
        set filename [fileutil::tempfile]
        set fh [open $filename r]
        fconfigure $fh -translation binary
        qc::exec_proxy -timeout [expr {$timeout * 1000}] << $html $wkhtmltopdf --page-size A4 --encoding UTF-8 --print-media-type -q - $filename
        set pdf [read $fh]
        close $fh
        file delete $filename
        if { $encoding eq "base64" } {
            return [::base64::encode $pdf]
        } else {
            return $pdf
        }
    }
}

proc qc::html {tagName nodeValue args} {
    #| Generate an html node
    return "[html_tag $tagName {*}$args]$nodeValue</$tagName>"
}

proc qc::html_tag { tagName args } {
    #| Generate just the opening html tag
    set minimized [list compact checked declare readonly disabled selected defer ismap nohref noshade nowrap multiple noresize]
    set attributes {}
    foreach {name value} [qc::dict_exclude $args {*}$minimized] {
	lappend attributes "$name=\"[string map {< &lt; > &gt; & &amp; \" &#34;} $value]\""
    }
    foreach {name value} [qc::dict_subset $args {*}$minimized] {
	if { [string is true $value] } {
	    lappend attributes "$name=\"$name\""
	}
    }
    if { [llength $attributes]==0 } {
	return "<$tagName>"
    } else {
	return "<$tagName [join $attributes]>"
    }
}

proc qc::html_escape {html} {
    #| Convert html markup characters to HTML entities
    return [string map [list < "&lt;" > "&gt;" \" "&quot;" ' "&#39;" & "&amp;"] $html]
}

proc qc::html_unescape { text } {
    #| Convert html entities back to text
    return [string map {&lt; < &gt; > &amp; & &\#39; ' &\#34; \" &quot; \"} $text]
}

proc qc::html_hidden { args } {
    #| Create hidden fields from vars
    set html {}
    foreach name $args {
	append html [qc::html_tag input type hidden name $name value [upset 1 $name] id $name]\n
    }
    return $html
}

proc qc::html_hidden_set { args } {
    #| Create hidden fields from list of name value pairs.
    set html {}
    foreach {name value} $args {
	append html [qc::html_tag input type hidden name $name value $value id $name]\n
    }
    return $html
}

proc qc::html_list { list args } {
    #| Convert list into HTML list.
    set html [html_tag ul {*}$args]
    foreach item $list {
	append html [html li $item] \n
    }
    append html "</ul>\n"
    return $html
}

proc qc::html_a { link url args } {
    # Create a HTML hyperlink 
    lappend args href $url
    return [html a $link {*}$args]
}

proc qc::html_a_replace { link url args } {
    # Used to replace browser history state so browser back button will not record these urls.
    lappend args onclick "location.replace(this.href);return false;"
    return [html_a $link $url {*}$args]
}

proc qc::html_id { name {value UNDEF}} {
    #| Wrap value in span tag and give it an ID
    if {[string equal $value UNDEF]} {
	qc::upcopy 1 $name value
    }
    default value ""
    return [html span $value id $name]
}

proc qc::html_menu { lmenu } {
    #| Join items to form a horizontal menu
    return [join $lmenu " &nbsp;<b>|</b>&nbsp; "]
}

proc qc::html_paragraph_layout {args} {
    #| Construct paragraph elements as a bold title with the detail below it by default.
    set html {}
    foreach {label detail} $args {
	append html "<p><b>$label</b><br>$detail</p>"
    }
    return $html
}

proc qc::html2text { html } {
    #| Wrapper for html2text. Input encoding UTF-8, Output encoding UTF-8
    set html [string map [list "&#8209;" -] $html] 
    qc::try {
	return [encoding convertfrom utf-8 [exec_proxy [qc::which html2text] -utf8 -nobs << [encoding convertto utf-8 $html]]]
    } {
	# html2text unable to convert (possibly invalid html).
	# Return text by removing all html tags and any style and script elements.
	if { [regexp -nocase {<body>.*</body>} $html body] } {
	    # try to extract the body element.
	    set html $body
	} 
	return [regsub -all -nocase {<[^>]*>|<script[^>]*>.*?</script>|<style[^>]*>.*?</style>} $html ""]
    }
}

proc qc::html_info_tables {args} {
    # WACKY
    #| Foreach dict in args return a table with 2 columns with name value in each row
    set cols {
	{class bold}
	{}
    }
    set class column
    foreach dict $args {
	set tbody {}
	foreach {name value} $dict {
	    lappend tbody [list $name $value]
	}
	lappend row [qc::html_table cols $cols class $class tbody $tbody]
    }
    return [qc::html_table class "columns-container" tbody [list $row]]
}

proc qc::html_styles2inline {html} {
    #| Applies defined styles in html head as inline styles for relevant elements in body
    set styles [regexp -all -inline {<style[^>]*>[^<]*</style>} $html]
    #regsub -all {<style[^>]*>([^<]*)</style>} $html {} html
    foreach style $styles {
	regexp {<style[^>]*>([^<]*)</style>} $style -> style
	set html [qc::html_style2inline $html $style]
    }
    return $html
}

proc qc::html_style2inline {html style} {
    #| Helper proc for qc::html_styles2inline
    set data [qc::css_parse $style]
    package require tdom
    dom parse -html $html doc
    foreach {selector styles} $data {
      	set nodes {}
	set xpath ""
	foreach part $selector {
	    if { [regexp {^[a-zA-Z][a-zA-Z0-9]*$} $part] } {
		# HTML element
		append xpath //$part
	    }  elseif { [regexp {^\.([a-zA-Z][a-zA-Z0-9\-]*(?:\.[a-zA-Z][a-zA-Z0-9\-]*)*)$} $part -> classes] } {
		# .class.other-class selector
		append xpath //*
                foreach class [split $classes "."] {
                    append xpath \[contains(@class,\"$class\")\]
                }
	    }  elseif { [regexp {^([a-zA-Z][a-zA-Z0-9]*)\.([a-zA-Z][a-zA-Z0-9\-]*(?:\.[a-zA-Z][a-zA-Z0-9\-]*)*)$} $part -> tag classes] } {
		# tag.class.other-class selector
		append xpath //$tag
                foreach class [split $classes "."] {
                    append xpath \[contains(@class,\"$class\")\]
                }
	    } elseif { [regexp {^#([a-zA-Z][a-zA-Z0-9\-\_]*)$} $part -> id] } {
		# #id selector
                append xpath //*\[contains(@id,\"$id\")\]
	    } elseif { [regexp {^#([a-zA-Z][a-zA-Z0-9\-\_]*)\.([a-zA-Z][a-zA-Z0-9\-]*(?:\.[a-zA-Z][a-zA-Z0-9\-]*)*)$} $part -> id classes] } {
		# #id.class.otherclass selector
                append xpath //*\[contains(@id,\"$id\")\]
                foreach class [split $classes "."] {
                    append xpath \[contains(@class,\"$class\")\]
                }
	    } elseif { [regexp {^([a-zA-Z][a-zA-Z0-9]*)#([a-zA-Z][a-zA-Z0-9\-\_]*)$} $part -> tag id] } {
		# tag#id selector
		append xpath //$tag\[contains(@id,\"$id\")\]
	    } elseif { [regexp {^([a-zA-Z][a-zA-Z0-9]*):nth-child\(([0-9]+)\)$} $part -> tag nth_child] } {
		# tag:nth-child() selector
		append xpath //$tag\[position()=$nth_child\]
	    }
	}
        set nodes [$doc selectNodes $xpath]

	foreach node $nodes {
	    if { [$node hasAttribute style] } {
		$node setAttribute style [style_set [$node getAttribute style] {*}$styles]
	    } else {
		$node setAttribute style [style_set "" {*}$styles]
	    }
	}
    }
    set html [$doc asHTML  -escapeNonASCII -htmlEntities]
    $doc delete
    return $html
}

proc qc::html_col_styles_apply2td {html} {
    #| Applies any relevent col styles as inline styles on td, tr, or tfoot elements
    #| Useful for correct html rendering in email clients
    set data {}
    set styles [regexp -all -inline {<style[^>]*>[^<]*</style>} $html]
    foreach style $styles {
	regexp {<style[^>]*>([^<]*)</style>} $style -> style
	set data [dict merge $data [qc::css_parse $style]]
    }
    # Apply col styles to td elements in all tables
    package require tdom
    dom parse -html $html doc
    foreach table [$doc selectNodes //table] {
	set col_number 1
	foreach col [$table selectNodes colgroup/col] {
	    if { [$col hasAttribute style] } {
		set style [$col getAttribute style]
	    } else {
		set style ""
	    }
	    if { [$col hasAttribute class] } {
		set class [$col getAttribute class] 
		foreach selector [list .$class col.$class] {
		    if { [dict exists $data $selector] } {
			set style [style_set $style {*}[dict get $data $selector]]
		    }
		}
	    }
	    if { [ne $style ""] } {
		foreach td [$table selectNodes "tbody/tr/td\[$col_number\] | tfoot/tr/td\[$col_number\]"] {
		    if { [$td hasAttribute style] } {
			$td setAttribute style [style_set [$td getAttribute style] {*}[qc::css_rule2dict $style]]
		    } else {
			$td setAttribute style [style_set "" {*}[qc::css_rule2dict $style]]
		    }
		}
	    }
	    incr col_number
	}
    }
    set html [$doc asHTML  -escapeNonASCII -htmlEntities]
    $doc delete
    return $html
}

proc qc::html_clean {html} {

    # Get rid of unnecessary tags
    regsub -all -- {<(/?o:|/?st[0-9]|!\[|\?xml)[^>]*>} $html {} html
  
    # remove extra lines
    regsub -all -- {(\n\r){2,}} $html {} html
    regsub -all { +>} $html {>} html
    regsub -all {< +} $html {<} html

    set start 0
    while { $start<[string length $html] && \
		[regexp -indices -start $start -- {<([^ >]+) ([^<]+)>} $html match ielement iattributes] } {
	set element [string range $html [lindex $ielement 0] [lindex $ielement 1]]
	set attributes [string range $html [lindex $iattributes 0] [lindex $iattributes 1]]

	# minimized attributes
	regsub -all {(^| )(checked|selected|disabled)( |$)} $attributes {\1\2="\2"\3} attributes
	
	set count 0
	while { [regsub -all {(^| )([^= ]+) *= *([^\"' ]+)( |$)} $attributes {\1\2="\3"\4} attributes] && $count<10000} {
	    incr count 
	}
	
	set count 0
	while { [regsub -all {(^| )([^= ]+) *= *'([^']+)'( |$)} $attributes {\1\2="\3"\4} attributes] && $count<10000} {
	    incr count
	}
	
	set attributes [join [regexp -all -inline {[^= ]+=\"[^\"]+\"} $attributes]]

	set element [lower $element]
	if { [eq $attributes ""] } {
	    set replace "<$element>"
	} else {
	    set replace "<$element $attributes>"
	}

	set html [string replace $html [lindex $match 0] [lindex $match 1] $replace]

	set start [expr {[lindex $match 0]+[string length $replace]}]
    }

    set start 0
    while { $start<[string length $html] && \
		[regexp -indices -start $start -- {</?[A-Z]+>} $html match] } {
	set replace [lower [string range $html [lindex $match 0] [lindex $match 1]]]
	set html [string replace $html [lindex $match 0] [lindex $match 1] $replace]
	set start [expr {[lindex $match 0]+[string length $replace]}]
    }

    return $html
}

proc qc::html2textlite {html} {
    # Will try to expand this to deal with block and inline elements but initially just preserve whitespace and newlines.
    set html [string map [list <br> \r\n] $html]
    return [qc::strip_html $html]
}

proc qc::strip_html {html} {
    #| Returns a string that is the HTML with all the HTML tags removed
    return [regsub -all -- {<[^>]+>} $html ""]
}
