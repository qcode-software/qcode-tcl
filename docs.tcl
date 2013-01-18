#| Script to Create Docs |#
# Convert Markdown docs to HTML 
# Create page for each proc

package require qcode

proc proc_fqn {proc_name {namespace ::}} {
    #| fully qualified proc name
    if { ![regexp {^::} $namespace] } {
	set namespace "::$namespace"
    }
    return [namespace eval $namespace [list namespace origin $proc_name]]
}

proc proc_exists {proc_name {namespace  ::} } {
    if { [namespace eval $namespace [list namespace which $proc_name]] ne "" } {
	return true
    } else {
	return false
    }
}

proc namespace_search_list {proc_name namespace} {
    set proc_name [namespace tail $proc_name]
    set list [list $proc_name ::$proc_name]
    set temp $proc_name
    foreach ns [lreverse [qc::mcsplit $namespace ::]] {
	lappend list [set temp "${ns}::${temp}"]
	lappend list ::$temp
    }
    return $list
}

proc link {proc_name {namespace ::}} {
    #| Return an html link to another doc entry 
    # reserved words ?
    if { [qc::in {default eq ne} $proc_name] } {
	return $proc_name
    }
    # proc
    if { [proc_exists $proc_name $namespace] } {
	set fqpn [proc_fqn $proc_name $namespace]
	set short_name [namespace tail $fqpn]
	if { [namespace qualifiers $fqpn] ne "" } {
	    return [qc::html_a $proc_name "$short_name.html"]
	} else {
	    return $proc_name
	}
    }
    return $proc_name
}

proc proc_source_code { proc_name } {
    #| Return html version of proc definition with links to other procs used in the body

    set proc_name [proc_fqn $proc_name]
    set namespace [namespace qualifiers $proc_name]

    set largs {}
    foreach arg [info args $proc_name] {
	if { [info default $proc_name $arg value] } {
	    lappend largs [list $arg $value]
	} else {
	    lappend largs $arg
	}
    }
    set body [info body $proc_name]
    set body [qc::html_escape $body]
    
    # Escape characters used by subst i.e. []$\ 
    regsub -all {[][$\\]} $body {\\&} body
    # Command at the start of a line
    regsub -all -line {^([ \t]+)([a-zA-Z0-9_.-:]+)} $body {\1[link \2 $namespace]} body
    # Command invocation
    regsub -all -line {(\\\[)([a-zA-Z0-9_.-:]+)} $body {\1[link \2 $namespace]} body
    set body [subst $body]

    return "proc [string trimleft $proc_name :] \{$largs\} \{$body\}"
}

proc proc_description { proc_name } {
    #| Get the proc description from the hash-pipe comments
    set body [info body $proc_name]
    set lines {}
    foreach line [regexp -all -inline -line {^[ \t]*\#\|.*} $body] {
	lappend lines [string trim $line " \#|"]
    }
    return [join $lines <br>]
}

proc proc_usage {proc_name} {
    #| Return the proc usage 
    set largs {}
    foreach arg [info args $proc_name] {
	if { [info default $proc_name $arg value] } {
	    lappend largs "?${arg}?"
	} else {
	    lappend largs $arg
	}
    }
    return "[string trimleft [proc_fqn $proc_name] :] $largs"
}

proc proc_doc {proc_name} {
    # HTML documentation for a proc
    
    set namespace [namespace qualifiers $proc_name]
    set data {}
    foreach key [namespace_search_list [namespace tail $proc_name] $namespace] {
	if { [info exists doc::db($key)] } {
	    set data $doc::db($key)
	    break
	} 
    }
    set html "<!DOCTYPE html><html><head>"
    append html [qc::html title [string trimleft $proc_name :]]
    append html [qc::html link "" href ../default.css rel stylesheet type text/css]
    append html </head><body>
    append html [qc::html h1 [string trimleft $proc_name :]]
    
    # Parent
    set title Docs
    set url .
    if {[dict exists $data Parent] } {
	foreach key [namespace_search_list [dict get $data Parent] $namespace] {
	    if { [info exists doc::db($key)] } {
		set parent $doc::db($key)
		set title [expr {[dict exists $parent Title]?[dict get $parent Title]:"Docs"}]
		set url   [expr {[dict exists $parent Url]?[dict get $parent Url]:"/"}]
		# Change /site-based-urls to relative urls
		regsub ^/ $url ../ url
		break
	    }
	}
    }
    append html "part of [qc::html_a $title $url]"


    append html <hr>

    # Usage
    append html [qc::html h2 Usage]
    if { [dict exists $data Usage] } {
	append html [dict get $data Usage]
    } else {
	append html [proc_usage $proc_name]
    }
    # Description
    if { ![dict exists $data Description] } {
	set description [proc_description $proc_name]
    } else {
        set description [dict get $data Description]
    }
    set description [qc::strip_common_leading_whitespace $description]
    set description [markdown2html $description]
    append html [qc::html h2 Description]
    append html $description
    # Examples
    if { [dict exists $data Examples] } {
	append html [qc::html h2 Examples]
	set examples [dict get $data Examples]
        set examples [qc::strip_common_leading_whitespace $examples]
	# Trailing newline + space at end
	regsub -all {\n[ \t]+$} $examples {} examples
	# Escape html
	set examples [qc::html_escape $examples]
	# Highlight comments
	regsub -line -all {^\#.*} $examples {<span class="comment">&</span>} examples
	append html [qc::html pre $examples class example]
    }
    # See Also
    if { [dict exists $data "See Also"] } {
	append html [qc::html h2 "See Also"]
	append html [dict get $data "See Also"]
    } 
    # Source
    append html [qc::html h2 Source]
    append html [qc::html pre [proc_source_code $proc_name] class source]
    append html <hr>
    append html "&copy; 2004-2012 Qcode Software Limited"
    return $html
}

proc markdown2html {markdown} {
    return [exec ruby /var/lib/gems/1.8/gems/github-markdown-0.5.3/bin/gfm << $markdown]
}

if { [llength $argv]!=2 } {
    error "Usage docs.tcl directory namespace"
}
set dir [lindex $argv 0]
set ns [lindex $argv 1]

set list [lsort [info procs "::${ns}::*"]]

foreach proc_name $list {
    puts "$proc_name"
    if { [proc_exists $proc_name qc] } {
	set fqpn [proc_fqn $proc_name $ns]
	set short_name [namespace tail $fqpn]

	set html [proc_doc [proc_fqn $proc_name]]
	set filename $dir/$ns/${short_name}.html
	set handle [open $filename w+ 00644]
	puts -nonewline $handle $html
	close $handle
    }
}

# Convert markdown files to html
cd $dir
foreach file [glob *.md] { 
    set file [file rootname $file] ; 
    set html "<!DOCTYPE html><html><head>"
    append html [qc::html title [string trimleft $proc_name :]]
    append html [qc::html link "" href ../default.css rel stylesheet type text/css]
    append html </head><body>
    append html [markdown2html [read [set handle [open $file.md]]]]
    close $handle

    puts $file; 
    exec ruby  /var/lib/gems/1.8/gems/github-markdown-0.5.3/bin/gfm < $file.md > $file.html 
}
