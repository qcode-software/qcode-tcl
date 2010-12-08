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
# $Header: /home/bernhard/cvs/exf/tcl/qc::html_table_db.tcl,v 1.9 2003/11/23 12:16:00 bernhard Exp $

proc qc::html_table_db {args} {
    # cols tbody tfoot height id initialFocus enabled addURL updateURL deleteURL dataURL
    set varNames [args2vars $args]
 
    if { [info exists data] && ![info exists tbody] } {
	set tbody [qc::html_table_tbody_from_ldict $data $cols]
	ldelete varNames [lsearch $varNames data]
	lappend varNames tbody
    }

    if { [info exists table] && ![info exists tbody] } {
	set tbody [lrange $table 1 end]
	ldelete varNames [lsearch $varNames data]
	lappend varNames tbody
    }
    
    # col types
    # encode all text columns by escaping html
    set colIndex 0
    foreach col $cols {
	if { ![dict exists $col type] || [eq [dict get $col type] text] } {
	    dict set col type text
	    for {set rowIndex 0} {$rowIndex < [llength $tbody]} {incr rowIndex} {
		# Try to test if the cell exists but lindex only returns empty string
		if { [ne [set cell [lindex $tbody $rowIndex $colIndex]] ""] } {
		    lset tbody $rowIndex $colIndex [ns_quotehtml $cell]
		}
	    }
	}
	incr colIndex
    }
    set class clsDbGrid
    # rowHeight
    if { [info exists rowHeight] } {
	append html "<style type=\"text/css\">table.$class tr { height:${rowHeight}px;vertical-align:top}</style>"
    }
    default height 500
    default id oDbGrid
    default enabled true
    #
    if { [string is true $enabled] } {
	set headers [ns_conn outputheaders]
	ns_set update $headers Pragma no-cache
	ns_set update $headers Cache-Control no-cache
    }

    append html  "<div class=\"clsDbGridDiv\" style=\"height:$height\">\n"


    lappend varNames class id
    append html [qc::html_table [dict_from [lsort -unique $varNames]]]
    append html "</div>\n"
    append html "<div class=\"clsDbGridDivStatus\" forTable=\"$id\"> <table width=\"100%\"><tr><td></td><td align=\"right\"></td></tr></table> </div>\n"
    return $html
}

proc qc::html_table_db_flexgrid {args} {
    # cols tbody tfoot height id initialFocus enabled addURL updateURL deleteURL dataURL sortable
    set varNames [args2vars $args]
    if { [info exists rowHeight] } {
        append html "<style type=\"text/css\">table.clsDbFlexGrid tr { height:${rowHeight}px;vertical-align:top}</style>"
    }
    default id oDbFlexGrid
    default enabled true
    #
    if { [string is true $enabled] } {
        set headers [ns_conn outputheaders]
        ns_set update $headers Pragma no-cache
        ns_set update $headers Cache-Control no-cache
    }
    append html  "<div class=\"clsDbFlexGridDiv\">\n"

    set class clsDbFlexGrid
    lappend varNames class id
    set dict [dict_from [lsort -unique $varNames]]

    append html [qc::html_table $dict]
    append html "</div>\n"
    return $html
}
