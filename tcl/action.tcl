package provide qcode 2.6.4
namespace eval qc {
    namespace export action action_print action_print_page action_menu
}

proc qc::action { description url {actionKey ""} } {
    if { [eq "" $actionKey] } {
	return [html_a $description $url class action onclick "return actionConfirm(this)"]
    } else {
	return [html_a $description $url class action actionKey $actionKey onclick "return actionConfirm(this)"]
    }
}

proc qc::action_print { description url {actionKey ""} } {
    #| Return script action to print or link to view
    #
    # Global variable used to indicate whether it is necessary to include
    # the scriptX object
    global requireScriptX
    set requireScriptX true
    
    if { [eq "" $actionKey] } {
	return "[html span $description class action onclick "printURL('$url')"] ( [html_a "view" $url] ) "
    } else {
	return "[html span $description class action onclick "printURL('$url')" actionKey $actionKey] ( [html_a "view" $url] ) "
    }
}

proc qc::action_print_page {} {
    return [html span Print class action onclick "window.print()"]
}

proc qc::action_menu {conf object_state} {
    set lmenu {}
    # Reserve shortcuts for copy,cut and paste
    set usedkeys(c) 1
    set usedkeys(x) 1
    set usedkeys(v) 1
    set usedkeys(s) 1

    foreach dict $conf {
	dict2vars $dict label url states type confirm
	default confirm yes
	# ActionKey
	for {set i 0} {$i<[string length $label]} {incr i} {
	    set letter [string index $label $i]
	    if { ![info exist usedkeys([lower $letter])] } {
		set actionKey [string tolower $letter]
		set usedkeys([lower $letter]) 1
		set link_label "[string range $label 0 [expr {$i-1}]]<u>$letter</u>[string range $label [expr {$i+1}] end]"
		break
	    } else {
		set actionKey ""
		set link_label $label
	    }
	}
	if { ![info exists states] || [in $states $object_state] } {
	    if { [info exists type] && [eq $type print] } {
		lappend lmenu [qc::action_print $link_label $url $actionKey]
	    } else {
		if { $confirm } {
		    lappend lmenu [qc::action $link_label $url $actionKey]
		} else {
		    lappend lmenu [html_a $link_label $url]
		}
	    }
	}
    }
    return [html_menu $lmenu]
}
