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
# $Header: /home/bernhard/cvs/exf/tcl/url.tcl,v 1.9 2004/03/16 10:34:05 bernhard Exp $

proc qc::url { url args } {
    #| Take an url with or without url encoded vars
    #| and insert or replace the names in vars with the 
    #| values in callers namespace level $level
    #| Example:
    #| > set foo Hello
    #| There
    #| > set bar There
    #| There
    #| > url afile.html foo bar
    #| afile.html?foo=Hello&bar=There
    #
    # Are there existing encoded vars path?var1=name1...
    set dict [args2dict $args]
    if { [regexp {([^\?\#]+)\??(.*)} $url -> path query_string] } {
	foreach {name value} [split $query_string &=] {
	    set this([ns_urldecode $name]) [ns_urldecode $value]
	}
    } else {
	error "\"$url\" is not a valid URL."
    }
    # Reset required values overwriting old values
    array set this $dict
    # Recontruct the query string
    set pairs {}
    foreach {name value} [array get this] {
	lappend pairs "[url_encode $name]=[url_encode $value]"
    }
    if { [llength $pairs] != 0 } {
	return "$path?[join $pairs &]"
    } else {
	return $path
    }
}

proc qc::url_unset { url var_name } {
    #| Unset a url encoded variable in url
    if { [regexp {([^\?\#]+)\??(.*)} $url -> path query_string] } {
	foreach {name value} [split $query_string &=] {
	    set this([ns_urldecode $name]) [ns_urldecode $value]
	}
    } else {
	array set this {}
    }
    # Unset required value
    if { [info exists this($var_name)] } {
	unset this($var_name)
    }
    # Recontruct the query string
    set pairs {}
    foreach name [array names this] {
	lappend pairs "[url_encode $name]=[url_encode $this($name)]"
    }
    if { [llength $pairs] != 0 } {
	return "$path?[join $pairs &]"
    } else {
	return $path
    }
}

proc qc::url_to_html_hidden { url } {
    set html ""
    if { [regexp {([^\?\#]+)\??(.*)} $url -> path query_string] } {
	foreach {name value} [split $query_string &=] {
	    set this([ns_urldecode $name]) [ns_urldecode $value]
	}
    } else {
	array set this {}
    }
    append html [html_hidden_set [array get this]]
    return $html
}

proc qc::url_back { url args } {
    #| Link to url using next_url to come back 
    #| Preserve vars passed in via GET or POST
    foreach name $args {
	set value($name) [upset 1 $name]
    }
    set value(next_url) [url_here]
    return [url $url [array get value]]
}

proc qc::url_here {} {
    return [qc::form2url [qc::conn_url]]
}

proc url_encode {string {charset utf-8}} {
    return [string map {%2e . %2E . %7e ~ %7E ~ %2d - %2D - %5f _ %5F _} [ns_urlencode -charset $charset $string]]
}

proc url_path {url} {
    set path $url
    regexp {^([^\?]+)} $url -> path
    return $path
}