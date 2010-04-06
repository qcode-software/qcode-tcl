proc doc_link {name {title ""}} {
    # reserved words ?
    if { [in {default} $name] } {
	return $name
    }
    # proc
    if { [ne [info procs $name] ""] || [ne [info procs ::$name] ""] } {
	if { [eq $title ""] } {
	    return [html_a $name /doc/${name}.html]
	} else {
	    return [html_a $title /doc/${name}.html]
	}
    }
    # page
    if { [nsv_exists doc $name] } {
	if { [eq $title ""] && [dict exists [nsv_get doc $name] Title] } {
	    return [html_a [dict get [nsv_get doc $name] Title] $name.html]
	} else {
	    return [html_a $title $name.html]
	}
    }
    return $name
}

proc doc_list {args} {
    set list {}
    foreach proc_name $args {
	lappend list [doc_link $proc_name]
    }
    return [html_list $list]
}

proc tcl_proc_show { proc_name } {
    if { [eq [info procs $proc_name] ""] && [eq [info procs ::$proc_name] ""] } {
	error "The proc $proc_name does not exist"
    }
    set proc_name [namespace which $proc_name]
    set largs {}
    foreach arg [info args $proc_name] {
	if { [info default $proc_name $arg value] } {
	    lappend largs [list $arg $value]
	} else {
	    lappend largs $arg
	}
    }
    set body [info body $proc_name]
    set body [ns_quotehtml $body]
    
    # Escape characters used by subst i.e. []$\ 
    regsub -all {[][$\\]} $body {\\&} body
    regsub -all -line {^([ \t]+)([a-zA-Z0-9_.-:]+)} $body {\1[doc_link \2]} body
    regsub -all -line {(\\\[)([a-zA-Z0-9_.-:]+)} $body {\1[doc_link \2]} body
    set body [subst $body]

    return "proc [string trimleft $proc_name :] \{$largs\} \{$body\}"
}

proc tcl_proc_doc { procname } {
    set body [info body $procname]
    set lines {}
    foreach line [regexp -all -inline -line {^[ \t]*\#\|.*} $body] {
	lappend lines [string trim $line " \#|"]
    }
    return [join $lines <br>]
}

proc tcl_proc_usage {proc_name} {
    set largs {}
    foreach arg [info args $proc_name] {
	if { [info default $proc_name $arg value] } {
	    lappend largs "?${arg}?"
	} else {
	    lappend largs $arg
	}
    }
    return "$proc_name $largs"
}

proc doc {proc_name data} {
    nsv_set doc $proc_name $data
}

proc doc_urh {} {
    if { [param_exists testing] && [param testing] } {
	qc::reload [ns_library private]
    }

    regexp {^/doc/(.+).html$} [ns_conn url] -> name
    if { [llength [info procs $name]] } {
	if { [nsv_exists doc $name] } {
	    return_html [doc_proc2html $name [nsv_get doc $name]]
	} else {
	    return_html [doc_proc2html $name {}]
	}
    } elseif { [nsv_exists doc $name] } {
	return_html [doc2html $name [nsv_get doc $name]]
    } else {
	conn_marshal
    }
}

proc /doc/index.html {} {
    foreach name [lsort [nsv_array names doc]] {
	lappend list [doc_link $name]
    }

    set html <html><head>
    append html [qc::html title $name]
    append html [html style [doc_template_style] type text/css]
    append html </head><body>
    append html [html_list $list]
    append html </body></html>
    return_html $html
}


proc doc_proc2html {proc_name data} {
    set html <html><head>
    append html [qc::html title $proc_name]
    append html [html style [doc_template_style] type text/css]
    append html </head><body>
    append html [qc::html h1 $proc_name]
    
    # Parent
    if { [dict exists $data "Parent"] } {
	set parent [dict get $data Parent]
	set title [dict get [nsv_get doc $parent] Title]
	set url $parent.html
	append html "part of [qc::html_a $title $url]"
    } else {
	append html "part of [qc::html_a "documented procs" index.html]"
    }

    append html <hr>

    # Usage
    append html [qc::html h2 Usage]
    if { [dict exists $data Usage] } {
	append html [dict get $data Usage]
    } else {
	append html [tcl_proc_usage $proc_name]
    }
    # Description
    if { ![dict exists $data Description] } {
	dict set data Description [tcl_proc_doc $proc_name]
    }
    if { [dict exists $data Description] } {
	append html [qc::html h2 Description]
	#append html [doc_parse [dict get $data Description]]
	append html [subst -novariables [dict get $data Description]]
    } else {
	append html [tcl_proc_doc $proc_name]
    }
    # Examples
    if { [dict exists $data Examples] } {
	append html [qc::html h2 Examples]
	set examples [dict get $data Examples]
	# strip leading whitespace
	regsub -line -all {^\t} $examples {} examples
	# Trailing newline + space at end
	regsub -all {\n[ \t]+$} $examples {} examples
	# Escape html
	set examples [ns_quotehtml $examples]
	# Highlight comments
	regsub -line -all {^\#.*} $examples {<span class="comment">&</span>} examples
	append html [qc::html pre $examples class example]
    }
    # See Also
    if { [dict exists $data "See Also"] } {
	append html [qc::html h2 "See Also"]
	append html [subst [dict get $data "See Also"]]
    } 
    # Source
    append html [qc::html h2 Source]
    append html [qc::html pre [tcl_proc_show $proc_name] class source]
    append html <hr>
    append html "&copy; 2007 Qcode Software Limited"
    return $html
}

proc doc2html {name data} {
    set html <html><head>
    # Page Title
    if { [dict exists $data Title] } {
	set page_title [dict get $data Title]
    } else {
	# Complain ??
	set page_title $name
    }
    append html [qc::html title $page_title]
    append html [html style [doc_template_style] type text/css]
    append html </head><body>
    append html [qc::html h1 $page_title]

    # Parent
    if { [dict exists $data "Parent"] } {
	set parent [dict get $data Parent]
	set title [dict get [nsv_get doc $parent] Title]
	set url $parent.html
	append html "part of [qc::html_a $title $url]"
    } else {
	append html "part of [qc::html_a "documented procs" index.html]"
    }

    append html <hr>
   
    # Description
    if { [dict exists $data Description] } {
	#append html [qc::html h2 Description]
	set description [dict get $data Description]
	# strip leading whitespace
	regsub -line -all {^\t} $description {} description
	regsub -line -all {^ {8}} $description {} description

	# Escape TCL in <pre> sections
	set description [doc_escape_pre_tcl $description]
	set description [doc_escape_pre_html $description]
	set description [subst -novariables $description]

	append html $description
    } 
    # Examples
    if { [dict exists $data Examples] } {
	append html [qc::html h2 Examples]
	set examples [dict get $data Examples]
	# strip leading whitespace
	regsub -line -all {^\t} $examples {} examples
	# Trailing newline + space at end
	regsub -all {\n[ \t]+$} $examples {} examples
	# Escape html
	set examples [ns_quotehtml $examples]
	append html [qc::html pre $examples class example]
    }
    # See Also
    if { [dict exists $data "See Also"] } {
	append html [qc::html h2 "See Also"]
	append html [subst [dict get $data "See Also"]]
    } 
    append html <hr>
    append html "&copy; 2007 Qcode Software Limited"
    return $html
}

proc doc_parse { text } {
    # Go through documented procs to see if they appear in the text and then link them
    # Escape characters used by subst i.e. []$\ 
    regsub -all {[][$\\]} $text {\\&} text
    set procs [nsv_array names doc]
    foreach proc_name $procs {
	if { [string first $proc_name $text]!=-1 } {
	    regsub -all -line $proc_name $text {[doc_link &]} text
	}
    }
    set text [subst $text]

    # strip leading whitespace
    regsub -line -all {^\t} $text {} text
    # strip newline + space at start
    regsub {^[\n\t ]+} $text {} text
    # Trailing newline + space at end
    regsub -all {\n[ \t]+$} $text {} text

    set paras [mcsplit $text "\n\n"]
    set temp {}
    foreach para $paras {
	append temp <p>$para</p>
    }
    set text $temp

    # lists
    regsub -all {[][$\\]} $text {\\&} text
    regsub {((^|\n)[\t ]*\*[^\*\n]+)+} $text {[wiki2html_list {&}]} text
    set text [subst $text]


    # Replace newlines with <BR>
    regsub -all {(.)\n(.)} $text "\\1<BR>\n\\2" text

    return $text
}

proc doc_escape_pre_tcl {string} {
    set start 0
    set start_tag {<pre class="example">}
    set end_tag {</pre>}
    while { [set start [string first $start_tag $string $start]]!=-1 } {
	set start [expr {$start + [string length $start_tag]}]
	set end [string first $end_tag $string $start]
	set end [expr {$end-1}]
	set string [string replace $string $start $end [string map {\[ \\[ \] \\] \$ \\$ \\ \\\\} [string range $string $start $end]]]
	set start [expr {$end+[string length $end_tag]}]
    }
    return $string
}

proc doc_escape_pre_html {string} {
    set start 0
    set start_tag {<pre class="example">}
    set end_tag {</pre>}
    while { [set start [string first $start_tag $string $start]]!=-1 } {
	set start [expr {$start + [string length $start_tag]}]
	set end [string first $end_tag $string $start]
	set end [expr {$end-1}]
	set string [string replace $string $start $end [ns_quotehtml [string range $string $start $end]]]
	set start [expr {$end+[string length $end_tag]}]
    }
    return $string
}

proc wiki2html_list {string} {
    #set string [join $args]
    regsub -all -line {^[\t ]*\*([^\*]+)$} $string {<li>\1</li>} string
    return <ul>$string</ul>
}

proc doc_template_style {} {
    return {
	body {
	    font-size: 100%; margin-left: 5%; margin-right: 5%; font-family: arial, helvetica, sans-serif
	}
	h1 {
	    margin-top:15px;
	    margin-bottom:5px;
	    font-size:180%;
	}
	h2 {
	    margin-top:15px;
	    margin-bottom:5px;
	    font-size:150%;
	}
	h3 {
	    margin-top:10px;
	    margin-bottom:3px;
	    font-size:110%;
	}
	h4 {
	    margin-top:10px;
	    margin-bottom:1px;
	    font-size:105%;
	}
	pre.example {
	    font-family: courier;
	    background-color: #e8f3ff;
	    padding:10px;
	    margin-top:10px;
	    margin-bottom:15px;
	    border-style: solid;
	    border-width:1px;
	    border-color:#0099ff;
	}
	pre.source {
	    font-family: courier;
	    background-color: #ffffcc;
	    border-style: solid;
	    border-width:1px;
	    border-color:#663300;
	    padding:10px;
	    margin:5px;
	    font-size:95%;
	}
	pre.psql {
	    font-family: courier;
	    color:black;
	    background-color:wheat;
	    padding:10px;
	    margin:5px;
	    border-style: solid;
	    border-width:1px;
	    border-color:brown;
	}
	span.comment { color:maroon;font-weight:bold; }
	div.indent {
	    margin-left:40px;
	    padding-left:10px;
	    border-left:solid 2px brown;
	}
	table.clsFlexGrid th {
	    border-width:1px;
	    border-style:solid;
	    border-color:#aca899;
	    background-color:#ece9d8;
	    color:black;
	    font-weight:bold;
	    text-align:center;
	    padding-left:8px;
	    padding-right:8px;
	}
	
	table.clsFlexGrid { 
	    border-collapse:collapse;
	    border-width:1px;
	    border-style:solid;
	    border-color:#aca899;
	}
	
	table.clsFlexGrid td {
	    border:solid 1px #aca899;
	    padding-left:3px;
	    padding-right:3px;
	}
	
	table.clsFlexGrid tr {
	    vertical-align:top;
	}
	
	table.clsFlexGrid tfoot {
	    font-weight:bold;
	}
	
	table.clsFlexGrid thead th.clsSorted {
	    background:#FFFFE9;
	}
	
	table.clsFlexGrid col {
	    padding-left:2px;
	    padding-right:15px;

	}
	
	table.clsFlexGrid col.clsNumber { 
	    text-align:right;
	    padding-left:15px;
	    padding-right:2px;
	}
	table.clsFlexGrid col.clsMoney { 
	    text-align:right;
	    padding-left:15px;
	    padding-right:2px;
	}
	table.clsFlexGrid col.clsCenter {
	    text-align:center;
	    padding-left:2px;
	    padding-right:2px;
	}
	table.clsFlexGrid col.clsRight {
	    text-align:right;
	    padding-left:15px;
	    padding-right:2px;
	}
	table.clsFlexGrid col.clsInteger {
	    text-align:right;
	    padding-left:15px;
	    padding-right:2px;
	}
	
    }
}