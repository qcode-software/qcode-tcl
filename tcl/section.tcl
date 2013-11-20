package provide qcode 2.0
package require doc
namespace eval qc {
    namespace export section section_menu
}

proc qc::section {conf section default_url {section_var section}} {
    set html [qc::section_menu $conf $section $default_url $section_var]
    foreach dict $conf {
	if { [string equal [dict get $dict label] $section] } {
	    set cmd [dict get $dict content]
	    append html [eval $cmd]
	    return $html
	}
    }
}

proc qc::section_menu {conf section default_url section_var} {
    set lmenu {}
    foreach dict $conf {
	set label [dict get $dict label]

        if { [dict exists $dict class] } {
            set class [dict get $dict class]
        } else {
            set class ""
        }

	# AccessKey
	for {set i 0} {$i<[string length $label]} {incr i} {
	    set letter [string index $label $i]
	    if { ![info exist usedkeys($letter)] } {
		set accesskey [string tolower $letter]
		set usedkeys($letter) 1
		set link_label "[string range $label 0 [expr {$i-1}]]<u>$letter</u>[string range $label [expr {$i+1}] end]"
		break
	    } else {
		set accesskey .
		set link_label $label
	    }
	}

	# Spacer - TLC
	if { [dict exists $dict type] && [string equal [dict get $dict type] spacer] } {
            lappend class "spacer"
	    lappend lmenu [html span "" style "width:[dict get $dict width]px" class $class]
	    continue
	}

	# Use default url with section
	if {[string equal $label $section]} {
            lappend class "selected"
	    lappend lmenu [html span $label class $class]
	} else {
	    if { [dict exists $dict count] } {
		set count [dict get $dict count]
		lappend lmenu [html span "[html_a $link_label [url $default_url $section_var $label] accesskey $accesskey] ($count)" class $class]
	    } else {
		lappend lmenu [html span [html_a $link_label [url $default_url $section_var $label] accesskey $accesskey] class $class]
	    }
	}
    }
    return [html div [join $lmenu ""] class "section-menu"]
}


