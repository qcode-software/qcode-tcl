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
    return [join $lines <br/>]
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

proc md_h1 {string} {
    return "\n$string\n[string repeat "=" [string length $string]]\n\n"
}

proc md_h2 {string} {
    return "\n$string\n[string repeat "-" [string length $string]]\n"
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
    
    append md [md_h1 [string trimleft $proc_name :]]
    
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
    append md "part of \[$title\]($url)\n"


    # Usage
    append md [md_h2 Usage]
    if { [dict exists $data Usage] } {
	append md "`[dict get $data Usage]`\n"
    } else {
	append md "`[proc_usage $proc_name]`\n"
    }
    # Description
    if { ![dict exists $data Description] } {
	set description [proc_description $proc_name]
    } else {
        set description [string trim [dict get $data Description]]
    }
    set description [qc::strip_common_leading_whitespace $description]
    append md [md_h2 Description]
    append md "$description\n"
    # Examples
    if { [dict exists $data Examples] } {
	append md [md_h2 Examples]
	set examples [dict get $data Examples]
        set examples [qc::strip_common_leading_whitespace $examples]
	# Trailing newline + space at end
	regsub -all {\n[ \t]+$} $examples {} examples
	# Escape html
	set examples [qc::html_escape $examples]
	# Highlight comments
	#regsub -line -all {^\#.*} $examples {<span class="comment">&</span>} examples
	append md "```tcl\n$examples\n```\n"
    }
    # See Also
    if { [dict exists $data "See Also"] } {
	append md [md_h2 "See Also"]
	append md [dict get $data "See Also"]
    } 
  
    append md {
----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: www.qcode.co.uk "Qcode Software"
}

return [string trim $md]
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

	set md [proc_doc [proc_fqn $proc_name]]
	set filename $dir/${short_name}.md
	set handle [open $filename w+ 00644]
	puts -nonewline $handle $md
	close $handle
    }
}

