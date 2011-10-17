package provide qcode 1.1
package require doc
namespace eval qc {}
proc qc::html2pdf { args } {
    # usage html2pdf ?-encoding encoding? ?-timeout timeout? html
    args $args -encoding base64 -timeout 20 html
    if { ![in {base64 binary} $encoding] } {
        error "HTML2PDF: Unknown encoding $encoding"
    }

    set url [param pdfserver]

    set pdfDoc [qc::http_post -timeout $timeout -content-type "text/plain; charset=utf-8" -accept "text/plain; charset=utf-8" $url htmlblock $html outputencoding $encoding]

    return $pdfDoc
}

doc html2pdf {
    Examples {
        % html2pdf -encoding base64 -timeout 10 "<html><p>This is an HTML file to be converted to a PDF</p></html>"
        JVBERi0xLjQKMSAwIG9iago8PAovVGl0bGUgKP7/KQovUHJvZHVjZXIgKHdraHRtbHRvcGRmKQov
        Q3JlYXRpb25EYXRlIChEOjIwMTAwODIwMTIzMjI1KQo+PgplbmRvYmoKNCAwIG9iago8PAovVHlw
        ZSAvRXh0R1N0YXRlCi9TQSB0cnVlCi9TTSAwLjAyCi9jYSAxLjAKL0NBIDEuMAovQUlTIGZhbHNl
        Ci9TTWFzayAvTm9uZT4+CmVuZG9iago1IDAgb2JqClsvUGF0dGVybiAvRGV2aWNlUkdCXQplbmRv
        YmoKOCAwIG9iago8PAovVHlwZSAvQ2F0YWxvZwovUGFnZXMgMiAwIFIKPj4KZW5kb2JqCjYgMCBv
        ...
        % html2pdf -encoding binary -timeout 10 "<html><p>This is an HTML file to be converted to a PDF</p></html>"
        1 0 obj
        <<
        /Title (þÿ)
        ...
    }
}


proc qc::html {tagName nodeValue args} {
    #| Generate an html node
    if { [llength $args]==1 } {set args [lindex $args 0]}
    return "[html_tag $tagName $args]$nodeValue</$tagName>"
}

doc html {
    Examples {
	% html span "Hello There"
	<span>Hello There</span>
	%
	% html span "Hello There" class greeting
	<span class="greeting">Hello There</span>
	%
	% html span "Hello There" class greeting value Escape&Me
	<span class="greeting" value="Escape&amp;Me">Hello There</span>
	%
	% html span "Hello There" class greeting id oSpan value "don't \"quote\" me"
	<span class="greeting" value="don't &#34;quote&#34; me">Hello There</span>
	%
	%  html span "Hello There" class greeting id oSpan value "don't \"quote\" me"
	<span class="greeting" id="oSpan" value="don't &#34;quote&#34; me">Hello There</span>
    }
}

proc qc::html_tag { tagName args } {
    #| Generate just the opening html tag
    if { [llength $args]==1 } {set args [lindex $args 0]}
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

doc html_tag {
    Examples {
	% html_tag input name firstname
	<input name="firstname">
	%
	% html_tag input name firstname value "Des O'Conner"
	<input name="firstname" value="Des O'Conner">
	%
	% html_tag input name firstname value "Des O'Conner" disabled yes
	<input name="firstname" value="Des O'Conner" disabled>
    }
}

proc qc::html_hidden { args } {
    #| Create hidden fields from vars
    if { [llength $args]==1 } {set args [lindex $args 0]}
    set html {}
    foreach name $args {
	append html [qc::html_tag input type hidden name $name value [upset 1 $name] id $name]\n
    }
    return $html
}

doc html_hidden {
    Examples {
	% set customer_key As234454g.4/2
	% html_hidden customer_key
	<input type="hidden" name="customer_key" value="As234454g.4/2" id="customer_key">
	%
	%  set order_key 66524F.kL
	% html_hidden customer_key order_key
	<input type="hidden" name="customer_key" value="As234454g.4/2" id="customer_key">
	<input type="hidden" name="order_key" value="66524F.kL" id="order_key">
    }
}

proc qc::html_hidden_set { args } {
    #| Create hidden fields from list of name value pairs.
    if { [llength $args]==1 } {set args [lindex $args 0]}
    set html {}
    foreach {name value} $args {
	append html [qc::html_tag input type hidden name $name value $value id $name]\n
    }
    return $html
}

doc html_hidden_set {
    Examples {
	% html_hidden_set customer_key As234454g.4/2 order_key 66524F.kL
	<input type="hidden" name="customer_key" value="As234454g.4/2" id="customer_key">
	<input type="hidden" name="order_key" value="66524F.kL" id="order_key">
    }
}

proc qc::html_list { list } {
    #| Convert list into HTML list.
    set html "<ul>\n"
    foreach item $list {
	append html "<li>$item</li>\n"
    }
    append html "</ul>\n"
    return $html
}

doc html_list {
    Examples {
	% set list [list one two three four]
	one two three four
	% html_list $list
	<ul>
	<li>one</li>
	<li>two</li>
	<li>three</li>
	<li>four</li>
	</ul>
    }
}

proc qc::html_a { link url args } {
    # Create a HTML hyperlink 
    if { [llength $args]==1 } {set args [lindex $args 0]}
    lappend args href $url
    return [html a $link $args]
}

doc html_a {
    Examples {
	% html_a Google http://www.google.co.uk 
	<a href="http://www.google.co.uk">Google</a>
	%
	% html_a Google http://www.google.co.uk title "Google Search" class highlight
	<a title="Google Search" class="highlight" href="http://www.google.co.uk">Google</a>
    }
}

proc qc::html_a_replace { link url args } {
    # Used to replace browser history state so browser back button will not record these urls.
    lappend args onclick "location.replace(this.href);return false;"
    return [html_a $link $url $args]
}

doc html_a {
    Examples {
	% html_a_replace Google http://www.google.co.uk 
	<a href="http://www.google.co.uk" onclick="location.replace(this.href);return false;">Google</a>
	%
	% html_a_replace Google http://www.google.co.uk title "Google Search" class highlight
        <a title="Google Search" class="highlight" href="http://www.google.co.uk" onclick="location.replace(this.href);return false;">Google</a>
    }
}



proc qc::html_id { name {value UNDEF}} {
    #| Wrap value in span tag and give it an ID
    if {[string equal $value UNDEF]} {
	upcopy 1 $name value
    }
    default value ""
    return [html span $value id $name]
}

doc html_id {
    Examples {
	% html_id total 23.50
	<span id="total">23.50</span>
	
    }
}

proc qc::html_menu { args } {
    #| Join items to form a horizontal menu
    if { [llength $args]==1 } {set args [lindex $args 0]}
    return [join $args " &nbsp;<b>|</b>&nbsp; "]
}

doc html_menu {
    Examples {
	% html_menu [html_a Sales sales.html] [html_a Purchasing sales.html] [html_a Accounts sales.html]
	<a href="sales.html">Sales</a> &nbsp;|&nbsp; <a href="sales.html">Purchasing</a> &nbsp;|&nbsp; <a href="sales.html">Accounts</a>
    }
}

proc qc::html_paragraph_layout {args} {
    #| Construct paragraph elements as a bold title with the detail below it by default.
    args $args -deliminator <br> -- args
    if { [llength $args]==1 } {set args [lindex $args 0]}
    set html {}
    foreach {label detail} $args {
	append html "<p><b>$label</b>$deliminator$detail</p>"
    }
    return $html
}

doc html_paragraph_layout {
    Examples {
	% html_paragraph_layout Name "Jimmy Tarbuck" Venue "Palace Ballroom"
	<p><b>Name</b><br>Jimmy Tarbuck</p><p><b>Venue</b><br>Palace Ballroom</p>

	% html_paragraph_layout -deliminator ": " Name "Jimmy Tarbuck" Venue "Palace Ballroom"
	<p><b>Name</b>: Jimmy Tarbuck</p><p><b>Venue</b>: Palace Ballroom</p>
    }
}

proc qc::html2text { html } {
    #| Wrapper for html2text 
    set html [string map [list "&#8209;" -] $html]
    if { ![nsv_exists which html2text] } {
	nsv_set which html2text [exec_proxy which html2text]
    }
    return [exec_proxy [nsv_get which html2text] -nobs << $html]
}

proc qc::html_info_tables {args} {
    #| Foreach dict in args return a table with 2 columns with name value in each row
    set cols {
	{class clsBold}
	{}
    }
    set class cl
    foreach dict $args {
	set tbody {}
	foreach {name value} $dict {
	    lappend tbody [list $name $value]
	}
	lappend row [qc::html_table cols $cols class $class tbody $tbody]
    }
    return [qc::html_table class clsColumar tbody [list $row]]
}

doc html_info_tables {
    Examples {
	% html_info_tables {Name "Jimmy Tarbuck" Venue "Palace Ballroom"} {Name "Des O'Conner" Venue "Royal Palladium"}
	<table class="clsColumar">
	<tbody>
	<tr>
	<td><table class="cl">
	<colgroup>
	<col class="clsBold">
	<col>
	</colgroup>
	<tbody>
	<tr>
	<td>Name</td>
	<td>Jimmy Tarbuck</td>
	</tr>
	<tr>
	<td>Venue</td>
	<td>Palace Ballroom</td>
	</tr>
	</tbody>
	</table>
	</td>
	<td><table class="cl">
	<colgroup>
	<col class="clsBold">
	<col>
	</colgroup>
	<tbody>
	<tr>
	<td>Name</td>
	<td>Des O'Conner</td>
	</tr>
	<tr>
	<td>Venue</td>
	<td>Royal Palladium</td>
	</tr>
	</tbody>
	</table>
	</td>
	</tr>
	</tbody>
	</table>
    }
}

proc qc::html_style2inline {html style} {
    set data [qc::css_parse $style]
    dom parse -html $html doc
    foreach {selector styles} $data {
	set nodes {}
	set xpath ""
	foreach part $selector {
	    if { [regexp {^[a-zA-Z][a-zA-Z0-9]*$} $part] } {
		# HTML element
		append xpath //$part
	    }  elseif { [regexp {^\.([a-zA-Z][a-zA-Z0-9]*)$} $part -> class] } {
		# .class selector
		append xpath //*\[contains(@class,\"$class\")\]
	    }  elseif { [regexp {^([a-zA-Z][a-zA-Z0-9]*)\.([a-zA-Z][a-zA-Z0-9]*)$} $part -> tag class] } {
		# tag.class selector
		append xpath //$tag\[contains(@class,\"$class\")\]
	    } elseif { [regexp {^#([a-zA-Z][a-zA-Z0-9]*)$} $part -> id] } {
		# #id selector
		append xpath //*\[contains(@id,\"$id\")\]
	    }  elseif { [regexp {^([a-zA-Z][a-zA-Z0-9]*)#([a-zA-Z][a-zA-Z0-9]*)$} $part -> tag id] } {
		# tag#id selector
		append xpath //$tag\[contains(@id,\"$id\")\]
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

proc qc::html_styles2inline {html} {
    set styles [regexp -all -inline {<style[^>]*>[^<]*</style>} $html]
    #regsub -all {<style[^>]*>([^<]*)</style>} $html {} html
    foreach style $styles {
	regexp {<style[^>]*>([^<]*)</style>} $style -> style
	set html [qc::html_style2inline $html $style]
    }
    return $html
}

proc qc::html_col_styles_apply2td {html} {
    set data {}
    set styles [regexp -all -inline {<style[^>]*>[^<]*</style>} $html]
    foreach style $styles {
	regexp {<style[^>]*>([^<]*)</style>} $style -> style
	set data [dict merge $data [qc::css_parse $style]]
    }
    # Apply col styles to td elements in all tables
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
		foreach td [$table selectNodes "tbody/tr/td\[$col_number\]"] {
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

#puts "element $element"
#puts "attributes $attributes"

	# minimized attributes
	regsub -all {(^| )(checked|selected|disabled)( |$)} $attributes {\1\2="\2"\3} attributes
	
#puts "minimized $attributes"

	set count 0
	while { [regsub -all {(^| )([^= ]+) *= *([^\"' ]+)( |$)} $attributes {\1\2="\3"\4} attributes] && $count<10000} {
#puts "quotes $attributes"
	    incr count 
	}
	
	set count 0
	while { [regsub -all {(^| )([^= ]+) *= *'([^']+)'( |$)} $attributes {\1\2="\3"\4} attributes] && $count<10000} {
#puts "single2quotes $attributes"	    
	    incr count
	}
	
	set attributes [join [regexp -all -inline {[^= ]+=\"[^\"]+\"} $attributes]]

#puts "final $attributes"
	set element [lower $element]
	if { [eq $attributes ""] } {
	    set replace "<$element>"
	} else {
	    set replace "<$element $attributes>"
	}

	set html [string replace $html [lindex $match 0] [lindex $match 1] $replace]

	set start [expr {[lindex $match 0]+[string length $replace]}]
	#puts "start $start is [string range $html $start end]"
    }


    set start 0
    while { $start<[string length $html] && \
		[regexp -indices -start $start -- {</?[A-Z]+>} $html match] } {
	set replace [lower [string range $html [lindex $match 0] [lindex $match 1]]]
	#puts "replace $replace"
	set html [string replace $html [lindex $match 0] [lindex $match 1] $replace]
	set start [expr {[lindex $match 0]+[string length $replace]}]
    }

    return $html
}

proc qc::html2textlite {html} {
    # Will try to expand this to deal with block and inline elements but initially just preserve whitespace and newlines.
    set html [string map [list <br> \r\n] $html]
    return [ns_striphtml $html]
}
