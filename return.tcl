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
# $Header: /home/bernhard/cvs/exf/tcl/qc::return.tcl,v 1.6 2004/03/16 10:34:04 bernhard Exp $

proc qc::return_html { string } { 
    ns_return 200 "text/html; charset=utf-8" $string
}

proc qc::return_xml { string } {
    ns_return 200 "text/xml; charset=utf-8" $string
}

proc qc::return_csv { string } { 
    ns_return 200 "text/csv; charset=utf-8" $string
}

proc qc::return_soap+xml { string } { 
    ns_return 200 "application/soap+xml; charset=utf-8" $string
}

proc qc::return_headers {} {
    set list {}
    lappend list "HTTP/1.0 200 OK"
    lappend list "Date: [ns_httptime [clock seconds]]"
    lappend list "MIME-Version: 1.0"
    lappend list "Content-Type: text/html"
    ns_write [join $list \r\n]
    ns_write \r\n\r\n
}

proc qc::return_headers_chunked {} {
    set list {}
    lappend list "HTTP/1.1 200 OK"
    lappend list "Date: [ns_httptime [clock seconds]]"
    lappend list "MIME-Version: 1.0"
    lappend list "Content-Type: text/html"
    lappend list "Transfer-Encoding: chunked"
    ns_write [join $list \r\n]
    ns_write \r\n\r\n
}

proc qc::return_chunks {string} {
    regsub -all {\r\n} $string \n string
    foreach line [split $string \n] {
	qc::return_chunk $line
    }
}

proc qc::return_chunk {string} {
    ns_write [format %X [string bytelength $string]]\r\n$string\r\n
}

proc qc::return_next { next_url } {   
    if { ![regexp {^https?://} $next_url] } {
	set port [ns_set iget [ns_conn headers] Port]
	set host [ns_set iget [ns_conn headers] Host]
	set next_url [string trimleft $next_url /]
	if { [ne $host ""] } {
	    if { [eq $port 443] } {
		set next_url "https://$host/$next_url"
	    } elseif { [eq $port 8443] } {
		set next_url "https://$host:8443/$next_url"
	    } else {
		set next_url "http://$host/$next_url"
	    }
	}
    }
    ns_returnredirect $next_url
}

proc ns_returnmoved {url} {
    ns_set update [ns_conn outputheaders] Location $url
    ns_return 301 "text/html" [subst \
  {<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
  <HTML>
  <HEAD>
  <TITLE>Moved</TITLE>
  </HEAD>
  <BODY>
  <H2>Moved</H2>
  <A HREF="$url">The requested URL has moved here.</A>
  <P ALIGN=RIGHT><SMALL><I>[ns_info name]/[ns_info patchlevel] on [ns_conn location]</I></SMALL></P>
  </BODY></HTML>}]
}


