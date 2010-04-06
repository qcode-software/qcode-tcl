# Copyright (C) 2001-2006, Bernhard van Woerden <bernhard@qcode.co.uk>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# $Header: /home/bernhard/cvs/exf/tcl/qc::action.tcl,v 1.5 2003/03/27 11:26:23 nsadmin Exp $

proc qc::action { description url {actionKey ""} } {
    if { [eq "" $actionKey] } {
	return [html_a $description $url [list class clsAction onclick "return actionConfirm(this)"]]
    } else {
	return [html_a $description $url [list class clsAction actionKey $actionKey onclick "return actionConfirm(this)"]]
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
	return "[html span $description [list class clsAction onclick "printURL('$url')" ]] ( [html_a "view" $url] ) "
    } else {
	return "[html span $description [list class clsAction onclick "printURL('$url')" actionKey $actionKey]] ( [html_a "view" $url] ) "
    }
}

proc qc::action_print_page {} {
    return [html span Print [list class clsAction onclick "window.print()"]]
}

proc qc::action_menu {conf object_state} {
    set lmenu {}
    # Reserve shortcuts for copy,cut and paste
    set usedkeys(c) 1
    set usedkeys(x) 1
    set usedkeys(v) 1
    set usedkeys(s) 1

    foreach dict $conf {
	set label [dict get $dict label]
	set url [dict get $dict url]
	set states [dict get $dict states]
	
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
	if { [in $states $object_state] } {
	    if { [dict exists $dict type] && [string equal [dict get $dict type] print] } {
		lappend lmenu [qc::action_print $link_label $url $actionKey]
	    } else {
		lappend lmenu [qc::action $link_label $url $actionKey]
	    }
	}
    }
    return [html_menu $lmenu]
}
