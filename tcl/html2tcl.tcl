namespace eval qc {
    package require tdom
    namespace export h h_tag tcl_escape tdom_node2tcl html2tcl
}

proc qc::h_tag { tag_name args } {
    #| Generate just the opening html tag
    set singleton_tags [list area base br col command embed hr img input link meta param source]
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