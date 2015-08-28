namespace eval qc {
    package require try
    package require tdom
    namespace export html2* html html_tag h h_tag html_escape html_unescape html_hidden html_hidden_set html_list html_a html_a_replace html_id html_menu html_paragraph_layout html_info_tables html_styles2inline html_style2inline html_col_styles_apply2td html_clean strip_html html2tcl tcl_escape tdom_node2tcl html_sanitize element_sanitize attribute_sanitize safe_elements_check safe_attributes_check safe_html_error_report safe_elements_error_report safe_attributes_error_report safe_elements safe_attributes response2html
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
    #| Deprecated - use qc::h instead.
    #| Generate an html node
    return "[html_tag $tagName {*}$args]$nodeValue</$tagName>"
}

proc qc::html_tag { tagName args } {
    #| Deprecated - use qc::h_tag instead.
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

proc qc::h_tag { tag_name args } {
    #| Generate just the opening html tag
    set singleton_tags [list area base br col command embed hr img input link meta param source]
    set minimized [list compact checked declare readonly disabled selected defer ismap nohref noshade nowrap multiple noresize]
    set attributes {}
   
    foreach {name value} [qc::dict_exclude $args {*}$minimized] {
        if { $name eq "classes" } {
            lappend attributes "class=\"[string map {< &lt; > &gt; & &amp; \" &#34;} [join $value]]\""
        } else {
            lappend attributes "$name=\"[string map {< &lt; > &gt; & &amp; \" &#34;} $value]\""
        }
    }
    foreach {name value} [qc::dict_subset $args {*}$minimized] {
	if { [string is true $value] } {
	    lappend attributes "$name=\"$name\""
	}
    }

    if { $tag_name in $singleton_tags && [llength $attributes]==0 } { 
	return "<$tag_name/>"
    } elseif { $tag_name in $singleton_tags } { 
        return "<$tag_name [join $attributes]/>"
    } elseif { [llength $attributes]==0 } {
	return "<$tag_name>"
    } else {
	return "<$tag_name [join $attributes]>"
    }
}

proc qc::h {tag_name args} {
    #| Generate an html node
    set singleton_tags [list area base br col command embed hr img input link meta param source]
    if { $tag_name in $singleton_tags } {
        return "[qc::h_tag $tag_name {*}$args]"
    } else {
        if { [llength $args]%2 == 0 } {
            return "[qc::h_tag $tag_name {*}$args]</$tag_name>"
        } else {
            return "[qc::h_tag $tag_name {*}[lrange $args 0 end-1]][lindex $args end]</$tag_name>"
        }
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

proc qc::tcl_escape {string} {
    #| Escape special tcl characters
    set map  {\" \\\" $ \\$ \\ \\\\ [ \\[ ] \\]}
    return [string map $map $string]
}

proc qc::tdom_node2tcl {node} {
    #| Convert tdom node to tcl 
    set singleton_tags [list area base br col command embed hr img input link meta param source]
    # Node Name
    set command {}
    lappend command h [qc::tcl_escape [$node nodeName]]
    # Node Attributes
    foreach attribute_name [$node attributes] {
        lappend command [qc::tcl_escape $attribute_name] \"[qc::tcl_escape [$node getAttribute $attribute_name]]\"
    }
    # Node Value
    if { [$node nodeName] ni $singleton_tags } {
        set list {}
        foreach child_node [$node childNodes] {
            if { [$child_node nodeName] eq "#text" } {
                lappend list [qc::tcl_escape [$child_node asXML]]
            } else {
                lappend list [qc::tdom_node2tcl $child_node]
            }
        } 
        lappend command \"[join $list ""]\"
    }
    return "\[[join $command]\]"
}

proc qc::html2tcl {html} {
    #| Convert HTML to tcl 
    dom parse -html $html doc    
    if { [llength [$doc childNodes]] > 0 } {
        return [qc::tdom_node2tcl [$doc firstChild]]
    } else {
        return ""
    }         
}

proc qc::html_sanitize {text} {
    #| Sanitizes the given text by removing any html and attributes that are not whitelisted.
    ::try {
        # wrap the text up in <root> to preserve text outwith the html
        set text [h root $text]
        set doc [dom parse -html $text]
        set root [$doc documentElement]
        
        if {$root eq ""} {
            return $text
        } else {
            qc::element_sanitize $root
            qc::attribute_sanitize $root
        }

        set html [$doc asHTML -escapeNonASCII -htmlEntities]
        $doc delete
        # remove the <div> tags we added earlier
        if { [regexp {^<root>(.*)</root>$} $html -> html_fragment]} {
            return $html_fragment
        } else {
            return -code error "The html returned by tDom was not what we expected."
        }
    } on error [list error_message options] {
        return -code error -errorcode HTML_PARSE $error_message
    }
}

proc qc::element_sanitize {node} {
    #| Checks the node and all of it's children for safe html elements removing those that are unsafe.
    if {[$node nodeType] eq "ELEMENT_NODE"} {
        set element [$node nodeName]
        set table_elements [list thead tbody tfoot tr td th]
        if {$element ni [safe_elements]} {
            $node delete
            return
        } elseif {$element eq "li"} {
            # top-level <li> elements are removed because they can break out of containing markup
            set ancestors [$node ancestor all]
            set found false
            foreach ancestor $ancestors {
                if {[$ancestor nodeName] eq "ul" || [$ancestor nodeName] eq "ol"} {
                    set found true
                    break
                }
            }
            if {! $found} {
                $node delete
                return
            }
            
        } elseif {$element in $table_elements} {
            # remove any table elements that are not contained in a table
            set ancestors [$node ancestor all]
            set found false
            foreach ancestor $ancestors {
                if {[$ancestor nodeName] eq "table"} {
                    set found true
                    break
                }
            }
            if {! $found} {
                $node delete
                return
            }
        }
    }
    
    foreach child [$node childNodes] {
        qc::element_sanitize $child
    }
}

proc qc::attribute_sanitize {node} {
    #| Checks the node and all of it's children for safe attributes removing those that are unsafe.
    set safe_attributes [dict get [safe_attributes] all]
    set nodeName [$node nodeName]
    # add a, img, or div attributes to the whitelist if the node is one of them
    if {[dict exists [safe_attributes] $nodeName]} {
        lappend safe_attributes {*}[dict get [safe_attributes] $nodeName]
    }
    # sanitize attributes of this node
    set attributes [$node attributes]
    foreach attribute $attributes {
        if {$attribute ni $safe_attributes} {
            $node removeAttribute $attribute
        } elseif {$attribute eq "href"} {
            set value [$node getAttribute $attribute]
            if {[regexp {^(.+):\/\/} $value] && ! [regexp "^(http|https|mailto):\/\/" $value]} {
                $node removeAttribute $attribute
            }
        } elseif {$attribute eq "src"} {
            set value [$node getAttribute $attribute]
            if {[regexp {^(.+):\/\/} $value] && ! [regexp "^(http|https):\/\/" $value]} {
                $node removeAttribute $attribute
            }
        } elseif {$attribute eq "class"} {
            set value [$node getAttribute $attribute]
            if {! [regexp {^language-} $value]} {
                $node removeAttribute $attribute
            }
        }
    }
    
    foreach child [$node childNodes] {
        qc::attribute_sanitize $child
    }
}

proc qc::safe_elements_check {node} {
    #| Checks the node and all of it's children for unsafe html elements.
    #| Returns true if all elements are safe otherwise false.
    if {[$node nodeType] eq "ELEMENT_NODE"} {
        set element [$node nodeName]
        set table_elements [list thead tbody tfoot tr td th]
        if {$element ni [safe_elements]} {
            return false
        } elseif {$element eq "li"} {
            # top-level <li> elements are considered unsafe because they can break out of containing markup
            set ancestors [$node ancestor all]
            set found false
            foreach ancestor $ancestors {
                if {[$ancestor nodeName] eq "ul" || [$ancestor nodeName] eq "ol"} {
                    set found true
                    break
                }
            }
            if {! $found} {
                return false
            }
            
        } elseif {$element in $table_elements} {
            # check for any table elements that are not contained in a table
            set ancestors [$node ancestor all]
            set found false
            foreach ancestor $ancestors {
                if {[$ancestor nodeName] eq "table"} {
                    set found true
                    break
                }
            }
            if {! $found} {
                return false
            }
        }
    }
    foreach child [$node childNodes] {
        if {! [qc::safe_elements_check $child]} {
            return false
        }
    }
    return true
}

proc qc::safe_attributes_check {node} {
    #| Checks the node and all of it's children for safe attributes.
    #| Returns true if all attributes are safe otherwise false.
    set safe_attributes [dict get [safe_attributes] all]
    set nodeName [$node nodeName]
    # add specific element attributes to the whitelist if the node is one of them
    if {[dict exists [safe_attributes] $nodeName]} {
        lappend safe_attributes {*}[dict get [safe_attributes] $nodeName]
    }
    set attributes [$node attributes]
    foreach attribute $attributes {
        if {$attribute ni $safe_attributes} {
            return false
        } elseif {$attribute eq "href"} {
            set value [$node getAttribute $attribute]
            if {[regexp {^(.+):\/\/} $value] && ! [regexp "^(http|https|mailto):\/\/" $value]} {
                return false
            }
        } elseif {$attribute eq "src"} {
            set value [$node getAttribute $attribute]
            if {[regexp {^(.+):\/\/} $value] && ! [regexp "^(http|https):\/\/" $value]} {
                return false
            }
        } elseif {$attribute eq "class"} {
            set value [$node getAttribute $attribute]
            if {! [regexp {^language-} $value]} {
                return false
            }
        }
    }
    foreach child [$node childNodes] {
        if {! [qc::safe_attributes_check $child]} {
            return false
        }
    }
    return true
}


proc qc::safe_html_error_report {text} {
    #| Reports all occurrences of unsafe html in the given text.
    ::try {
        # wrap the text up in <root> to preserve text outwith the html
        set text [qc::h root $text]
        set doc [dom parse -html $text]
        set root [$doc documentElement]
        if {$root eq ""} {
            $doc delete
            return {}
        } else {
            set unsafe_elements [qc::safe_elements_error_report $root]
            set unsafe_attributes [qc::safe_attributes_error_report $root]
            $doc delete
            return [lappend unsafe_elements {*}$unsafe_attributes]
        }
    } on error [list error_message options] {
        return [list [dict create node_value $text reason "Content could not be parsed. Check for unbalanced tags or quotations."]]
    }
}

proc qc::safe_elements_error_report {node} {
    #| Checks the node and all of it's children for unsafe html elements.
    #| Returns a list of dictionaries that specify unsafe elements.
    set unsafe {}
    if {[$node nodeType] eq "ELEMENT_NODE"} {
        set element [$node nodeName]
        set table_elements [list thead tbody tfoot tr td th]
        if {$element ni [qc::safe_elements]} {
            lappend unsafe [dict create node_value [$node asHTML -escapeNonASCII] element $element reason "Unsafe element: $element"]
        } elseif {$element eq "li"} {
            # top-level <li> elements are considered unsafe because they can break out of containing markup
            set ancestors [$node ancestor all]
            set found false
            foreach ancestor $ancestors {
                if {[$ancestor nodeName] eq "ul" || [$ancestor nodeName] eq "ol"} {
                    set found true
                    break
                }
            }
            if {! $found} {
                lappend unsafe [dict create node_value [$node asHTML -escapeNonASCII] element $element reason "List element without \"<ul>\" or \"<ol>\" ancestor"]
            }
            
        } elseif {$element in $table_elements} {
            # check for any table elements that are not contained in a table
            set ancestors [$node ancestor all]
            set found false
            foreach ancestor $ancestors {
                if {[$ancestor nodeName] eq "table"} {
                    set found true
                    break
                }
            }
            if {! $found} {
                lappend unsafe [dict create node_value [$node asHTML -escapeNonASCII] element $element reason "Table element without \"<table>\" ancestor"]
            }
        }
    }
    foreach child [$node childNodes] {
        foreach item [qc::safe_elements_error_report $child] {
            lappend unsafe $item
        }
    }
    return $unsafe
}

proc qc::safe_attributes_error_report {node} {
    #| Checks the node and all of it's children for unsafe attributes and values.
    #| Returns a list of dictionaries that specify unsafe items.
    set safe_attributes [dict get [qc::safe_attributes] all]
    set element [$node nodeName]
    # add specific element attributes to the whitelist if the node is one of them
    if {[dict exists [qc::safe_attributes] $element]} {
        lappend safe_attributes {*}[dict get [qc::safe_attributes] $element]
    }
    set attributes [$node attributes]
    set unsafe {}
    foreach attribute $attributes {
        if {$attribute ni $safe_attributes} {
            lappend unsafe [dict create node_value [$node asHTML -escapeNonASCII] element $element attribute $attribute reason "Unsafe attribute: $attribute"]
        } elseif {$attribute eq "href"} {
            set value [$node getAttribute $attribute]
            if {[regexp {^(.+):\/\/} $value] && ! [regexp "^(http|https|mailto):\/\/" $value]} {
                lappend unsafe [dict create node_value [$node asHTML -escapeNonASCII] element $element attribute $attribute attribute_value $value reason "Unsafe value \"$value\" for attribute \"$attribute\""]
            }
        } elseif {$attribute eq "src"} {
            set value [$node getAttribute $attribute]
            if {[regexp {^(.+):\/\/} $value] && ! [regexp "^(http|https):\/\/" $value]} {
                lappend unsafe [dict create node_value [$node asHTML -escapeNonASCII] element $element attribute $attribute attribute_value $value reason "Unsafe value \"$value\" for attribute \"$attribute\""]
            }
        } elseif {$attribute eq "class"} {
            set value [$node getAttribute $attribute]
            if {! [regexp {^language-} $value]} {
                lappend unsafe [dict create node_value [$node asHTML -escapeNonASCII] element $element attribute $attribute attribute_value $value reason "Unsafe value \"$value\" for attribute \"$attribute\""]
            }
        }
    }
    foreach child [$node childNodes] {
        foreach item [qc::safe_attributes_error_report $child] {
            lappend unsafe $item
        }
    }
    return $unsafe
}

proc qc::safe_elements {} {
    #| Returns a list of safe html elements.
    set safe_elements {}
    lappend safe_elements a
    lappend safe_elements b
    lappend safe_elements blockquote
    lappend safe_elements br
    lappend safe_elements code
    lappend safe_elements dd
    lappend safe_elements del
    lappend safe_elements div
    lappend safe_elements dl
    lappend safe_elements dt
    lappend safe_elements em
    lappend safe_elements h1
    lappend safe_elements h2
    lappend safe_elements h3
    lappend safe_elements h4
    lappend safe_elements h5
    lappend safe_elements h6
    lappend safe_elements h7
    lappend safe_elements h8
    lappend safe_elements hr
    lappend safe_elements i
    lappend safe_elements img
    lappend safe_elements ins
    lappend safe_elements kbd
    lappend safe_elements li
    lappend safe_elements ol
    lappend safe_elements p
    lappend safe_elements pre
    lappend safe_elements q
    lappend safe_elements ruby
    lappend safe_elements rt
    lappend safe_elements rp
    lappend safe_elements samp
    lappend safe_elements strong
    lappend safe_elements sub
    lappend safe_elements sup
    lappend safe_elements table
    lappend safe_elements tbody
    lappend safe_elements td
    lappend safe_elements tfoot
    lappend safe_elements th
    lappend safe_elements thead
    lappend safe_elements tr
    lappend safe_elements tt
    lappend safe_elements ul
    lappend safe_elements var
    lappend safe_elements root

    return $safe_elements
}

proc qc::safe_attributes {} {
    #| Returns a dict of {element, attributes} where attributes is a list of safe attributes for the given element.
    #| Includes element 'all' that applies to all elements.
    set list {}
    lappend list abbr
    lappend list accept
    lappend list accept-charset
    lappend list accesskey
    lappend list action
    lappend list align
    lappend list alt
    lappend list axis
    lappend list border
    lappend list cellpadding
    lappend list cellspacing
    lappend list char
    lappend list charoff
    lappend list charset
    lappend list checked
    lappend list cite
    lappend list class
    lappend list clear
    lappend list cols
    lappend list colspan
    lappend list color
    lappend list compact
    lappend list coords
    lappend list datetime
    lappend list dir
    lappend list disabled
    lappend list enctype
    lappend list for
    lappend list frame
    lappend list headers
    lappend list height
    lappend list hreflang
    lappend list hspace
    lappend list ismap
    lappend list label
    lappend list lang
    lappend list longdesc
    lappend list maxlength
    lappend list media
    lappend list method
    lappend list multiple
    lappend list name
    lappend list nohref
    lappend list noshade
    lappend list nowrap
    lappend list prompt
    lappend list readonly
    lappend list rel
    lappend list rev
    lappend list rows
    lappend list rowspan
    lappend list rules
    lappend list scope
    lappend list selected
    lappend list shape
    lappend list size
    lappend list span
    lappend list start
    lappend list summary
    lappend list tabindex
    lappend list target
    lappend list title
    lappend list type
    lappend list usemap
    lappend list valign
    lappend list value
    lappend list vspace
    lappend list width
    lappend list itemprop

    set safe_attributes [dict create]
    dict append safe_attributes a [list href]
    dict append safe_attributes img [list src]
    dict append safe_attributes div [list itemscope itemtype]
    dict append safe_attributes code [list class]
    dict append safe_attributes all $list

    return $safe_attributes
}

proc qc::response2html {} {
    #| Converts the global data structure to HTML
    return [h html [h body [h h1 "Placeholder"]]]
}
